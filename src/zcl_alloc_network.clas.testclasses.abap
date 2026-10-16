CLASS ltcl_alloc_network DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut  TYPE REF TO zcl_alloc_network.
    DATA mt_node TYPE zcl_alloc_network=>ty_node_tt.
    DATA mt_lane TYPE zcl_alloc_network=>ty_lane_tt.

    METHODS setup.

    METHODS add_node
      IMPORTING
        iv_id   TYPE string
        iv_type TYPE string.

    METHODS add_lane
      IMPORTING
        iv_from TYPE string
        iv_to   TYPE string
        iv_dist TYPE i.

    METHODS empty_network   FOR TESTING.
    METHODS counts_degrees  FOR TESTING.
    METHODS marks_isolated  FOR TESTING.
    METHODS ignores_unknown FOR TESTING.
    METHODS keeps_node_order FOR TESTING.
    METHODS connected_count FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_network IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_network( ).
  ENDMETHOD.

  METHOD add_node.
    DATA ls_node TYPE zcl_alloc_network=>ty_node.

    ls_node-node_id = iv_id.
    ls_node-node_type = iv_type.
    APPEND ls_node TO mt_node.
  ENDMETHOD.

  METHOD add_lane.
    DATA ls_lane TYPE zcl_alloc_network=>ty_lane.

    ls_lane-from_node = iv_from.
    ls_lane-to_node = iv_to.
    ls_lane-distance = iv_dist.
    APPEND ls_lane TO mt_lane.
  ENDMETHOD.

  METHOD empty_network.
    DATA(lt_degrees) = mo_cut->build( it_nodes = mt_node
                                      it_lanes = mt_lane ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_degrees ) exp = 0 ).
  ENDMETHOD.

  METHOD counts_degrees.
    add_node( iv_id = 'P1' iv_type = 'plant' ).
    add_node( iv_id = 'C1' iv_type = 'customer' ).
    add_lane( iv_from = 'P1' iv_to = 'C1' iv_dist = 10 ).

    DATA(lt_degrees) = mo_cut->build( it_nodes = mt_node
                                      it_lanes = mt_lane ).

    cl_abap_unit_assert=>assert_equals( act = lt_degrees[ 1 ]-outgoing exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_degrees[ 1 ]-incoming exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = lt_degrees[ 2 ]-outgoing exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = lt_degrees[ 2 ]-incoming exp = 1 ).
  ENDMETHOD.

  METHOD marks_isolated.
    add_node( iv_id = 'P1' iv_type = 'plant' ).
    add_node( iv_id = 'LONELY' iv_type = 'dc' ).
    add_lane( iv_from = 'P1' iv_to = 'C1' iv_dist = 10 ).

    DATA(lt_degrees) = mo_cut->build( it_nodes = mt_node
                                      it_lanes = mt_lane ).

    cl_abap_unit_assert=>assert_equals( act = lt_degrees[ 1 ]-isolated exp = abap_false ).
    cl_abap_unit_assert=>assert_equals( act = lt_degrees[ 2 ]-isolated exp = abap_true ).
  ENDMETHOD.

  METHOD ignores_unknown.
    add_node( iv_id = 'P1' iv_type = 'plant' ).
    add_lane( iv_from = 'P1' iv_to = 'GHOST' iv_dist = 5 ).

    DATA(lt_degrees) = mo_cut->build( it_nodes = mt_node
                                      it_lanes = mt_lane ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_degrees ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_degrees[ 1 ]-outgoing exp = 1 ).
  ENDMETHOD.

  METHOD keeps_node_order.
    add_node( iv_id = 'ZETA' iv_type = 'plant' ).
    add_node( iv_id = 'ALPHA' iv_type = 'dc' ).

    DATA(lt_degrees) = mo_cut->build( it_nodes = mt_node
                                      it_lanes = mt_lane ).

    cl_abap_unit_assert=>assert_equals( act = lt_degrees[ 1 ]-node_id exp = 'ZETA' ).
    cl_abap_unit_assert=>assert_equals( act = lt_degrees[ 2 ]-node_id exp = 'ALPHA' ).
  ENDMETHOD.

  METHOD connected_count.
    add_node( iv_id = 'P1' iv_type = 'plant' ).
    add_node( iv_id = 'LONELY' iv_type = 'dc' ).
    add_lane( iv_from = 'P1' iv_to = 'P1' iv_dist = 1 ).

    DATA(lt_degrees) = mo_cut->build( it_nodes = mt_node
                                      it_lanes = mt_lane ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->connected_count( lt_degrees ) exp = 1 ).
  ENDMETHOD.

ENDCLASS.
