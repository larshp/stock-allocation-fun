CLASS zcl_alloc_network DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_node,
             node_id   TYPE string,
             node_type TYPE string,
           END OF ty_node.
    TYPES ty_node_tt TYPE STANDARD TABLE OF ty_node WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_lane,
             from_node TYPE string,
             to_node   TYPE string,
             distance  TYPE i,
           END OF ty_lane.
    TYPES ty_lane_tt TYPE STANDARD TABLE OF ty_lane WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_degree,
             node_id   TYPE string,
             node_type TYPE string,
             outgoing  TYPE i,
             incoming  TYPE i,
             isolated  TYPE abap_bool,
           END OF ty_degree.
    TYPES ty_degree_tt TYPE STANDARD TABLE OF ty_degree WITH DEFAULT KEY.

    METHODS build
      IMPORTING
        it_nodes          TYPE ty_node_tt
        it_lanes          TYPE ty_lane_tt
      RETURNING
        VALUE(rt_degrees) TYPE ty_degree_tt.

    METHODS connected_count
      IMPORTING
        it_degrees      TYPE ty_degree_tt
      RETURNING
        VALUE(rv_count) TYPE i.
ENDCLASS.


CLASS zcl_alloc_network IMPLEMENTATION.

  METHOD build.
    DATA lo_out    TYPE REF TO zcl_alloc_key_agg_str.
    DATA lo_in     TYPE REF TO zcl_alloc_key_agg_str.
    DATA ls_degree TYPE ty_degree.
    DATA lv_out    TYPE menge_d.
    DATA lv_in     TYPE menge_d.

    LOOP AT it_nodes INTO DATA(ls_node).
      CLEAR ls_degree.
      ls_degree-node_id = ls_node-node_id.
      ls_degree-node_type = ls_node-node_type.
      APPEND ls_degree TO rt_degrees.
    ENDLOOP.

    " The endpoints are counted with one linear aggregation and looked up by
    " binary search, instead of scanning the whole count table once per lane.
    lo_out = NEW zcl_alloc_key_agg_str( ).
    lo_in = NEW zcl_alloc_key_agg_str( ).

    LOOP AT it_lanes INTO DATA(ls_lane).
      lo_out->add( iv_key      = ls_lane-from_node
                   iv_quantity = 1 ).
      lo_in->add( iv_key      = ls_lane-to_node
                  iv_quantity = 1 ).
    ENDLOOP.

    " Lanes that mention a node which is not in the node list are counted in the
    " aggregation but never read here, so they stay ignored as before.
    LOOP AT rt_degrees ASSIGNING FIELD-SYMBOL(<ls_degree>).
      lv_out = lo_out->find( iv_key = <ls_degree>-node_id ).
      lv_in = lo_in->find( iv_key = <ls_degree>-node_id ).

      <ls_degree>-outgoing = lv_out DIV 1.
      <ls_degree>-incoming = lv_in DIV 1.

      IF <ls_degree>-outgoing = 0 AND <ls_degree>-incoming = 0.
        <ls_degree>-isolated = abap_true.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD connected_count.
    LOOP AT it_degrees INTO DATA(ls_degree).
      IF ls_degree-isolated = abap_false.
        rv_count = rv_count + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
