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
  PRIVATE SECTION.
    TYPES: BEGIN OF ty_count,
             node_id TYPE string,
             out_cnt TYPE i,
             in_cnt  TYPE i,
           END OF ty_count.
    TYPES ty_count_tt TYPE STANDARD TABLE OF ty_count WITH DEFAULT KEY.

    METHODS bump
      IMPORTING
        it_counts        TYPE ty_count_tt
        iv_node          TYPE string
        iv_out           TYPE i
        iv_in            TYPE i
      RETURNING
        VALUE(rt_counts) TYPE ty_count_tt.
ENDCLASS.


CLASS zcl_alloc_network IMPLEMENTATION.

  METHOD bump.
    DATA ls_count TYPE ty_count.

    rt_counts = it_counts.

    READ TABLE rt_counts INTO ls_count WITH KEY node_id = iv_node.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    ls_count-out_cnt = ls_count-out_cnt + iv_out.
    ls_count-in_cnt = ls_count-in_cnt + iv_in.

    DELETE rt_counts WHERE node_id = iv_node.
    APPEND ls_count TO rt_counts.
  ENDMETHOD.

  METHOD build.
    DATA lt_counts TYPE ty_count_tt.
    DATA ls_count  TYPE ty_count.
    DATA ls_degree TYPE ty_degree.

    LOOP AT it_nodes INTO DATA(ls_node).
      CLEAR ls_degree.
      ls_degree-node_id = ls_node-node_id.
      ls_degree-node_type = ls_node-node_type.
      APPEND ls_degree TO rt_degrees.
    ENDLOOP.

    LOOP AT rt_degrees INTO ls_degree.
      CLEAR ls_count.
      ls_count-node_id = ls_degree-node_id.
      APPEND ls_count TO lt_counts.
    ENDLOOP.

    LOOP AT it_lanes INTO DATA(ls_lane).
      lt_counts = bump( it_counts = lt_counts
                        iv_node   = ls_lane-from_node
                        iv_out    = 1
                        iv_in     = 0 ).
      lt_counts = bump( it_counts = lt_counts
                        iv_node   = ls_lane-to_node
                        iv_out    = 0
                        iv_in     = 1 ).
    ENDLOOP.

    LOOP AT rt_degrees ASSIGNING FIELD-SYMBOL(<ls_degree>).
      READ TABLE lt_counts INTO ls_count
        WITH KEY node_id = <ls_degree>-node_id.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      <ls_degree>-outgoing = ls_count-out_cnt.
      <ls_degree>-incoming = ls_count-in_cnt.

      IF ls_count-out_cnt = 0 AND ls_count-in_cnt = 0.
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
