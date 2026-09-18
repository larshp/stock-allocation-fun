CLASS zcl_alloc_path DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_ids_tt TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_arc,
             from_node TYPE string,
             to_node   TYPE string,
             distance  TYPE i,
           END OF ty_arc.
    TYPES ty_arc_tt TYPE STANDARD TABLE OF ty_arc WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_result,
             found    TYPE abap_bool,
             distance TYPE i,
             hops     TYPE i,
             path     TYPE ty_ids_tt,
           END OF ty_result.

    METHODS shortest
      IMPORTING
        it_arcs          TYPE ty_arc_tt
        iv_from          TYPE string
        iv_to            TYPE string
      RETURNING
        VALUE(rs_result) TYPE ty_result.

  PRIVATE SECTION.
    CONSTANTS c_inf     TYPE i VALUE 1000000000.
    CONSTANTS c_max_hop TYPE i VALUE 1000.

    TYPES: BEGIN OF ty_dist,
             node_id  TYPE string,
             distance TYPE i,
             prev     TYPE string,
             visited  TYPE abap_bool,
           END OF ty_dist.
    TYPES ty_dist_tt TYPE STANDARD TABLE OF ty_dist WITH DEFAULT KEY.

    METHODS ensure_node
      IMPORTING
        it_dist        TYPE ty_dist_tt
        iv_node        TYPE string
      RETURNING
        VALUE(rt_dist) TYPE ty_dist_tt.

    METHODS set_dist
      IMPORTING
        it_dist        TYPE ty_dist_tt
        iv_node        TYPE string
        iv_distance    TYPE i
        iv_prev        TYPE string
      RETURNING
        VALUE(rt_dist) TYPE ty_dist_tt.

    METHODS mark_visited
      IMPORTING
        it_dist        TYPE ty_dist_tt
        iv_node        TYPE string
      RETURNING
        VALUE(rt_dist) TYPE ty_dist_tt.

ENDCLASS.


CLASS zcl_alloc_path IMPLEMENTATION.

  METHOD ensure_node.
    DATA ls_row TYPE ty_dist.

    rt_dist = it_dist.

    READ TABLE rt_dist INTO ls_row WITH KEY node_id = iv_node.
    IF sy-subrc = 0.
      RETURN.
    ENDIF.

    ls_row-node_id = iv_node.
    ls_row-distance = c_inf.
    APPEND ls_row TO rt_dist.
  ENDMETHOD.

  METHOD set_dist.
    DATA ls_row TYPE ty_dist.

    rt_dist = it_dist.

    READ TABLE rt_dist INTO ls_row WITH KEY node_id = iv_node.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    ls_row-distance = iv_distance.
    ls_row-prev = iv_prev.

    DELETE rt_dist WHERE node_id = iv_node.
    APPEND ls_row TO rt_dist.
  ENDMETHOD.

  METHOD mark_visited.
    DATA ls_row TYPE ty_dist.

    rt_dist = it_dist.

    READ TABLE rt_dist INTO ls_row WITH KEY node_id = iv_node.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    ls_row-visited = abap_true.

    DELETE rt_dist WHERE node_id = iv_node.
    APPEND ls_row TO rt_dist.
  ENDMETHOD.

  METHOD shortest.
    DATA lt_dist  TYPE ty_dist_tt.
    DATA lt_rev   TYPE ty_ids_tt.
    DATA ls_row   TYPE ty_dist.
    DATA ls_cur   TYPE ty_dist.
    DATA ls_arc   TYPE ty_arc.
    DATA lv_best  TYPE i.
    DATA lv_alt   TYPE i.
    DATA lv_guard TYPE i.
    DATA lv_cur   TYPE string.
    DATA lv_id    TYPE string.
    DATA lv_pos   TYPE i.

    LOOP AT it_arcs INTO ls_arc.
      lt_dist = ensure_node( it_dist = lt_dist iv_node = ls_arc-from_node ).
      lt_dist = ensure_node( it_dist = lt_dist iv_node = ls_arc-to_node ).
    ENDLOOP.

    lt_dist = ensure_node( it_dist = lt_dist iv_node = iv_from ).
    lt_dist = ensure_node( it_dist = lt_dist iv_node = iv_to ).
    lt_dist = set_dist( it_dist     = lt_dist
                        iv_node     = iv_from
                        iv_distance = 0
                        iv_prev     = '' ).

    IF iv_from = iv_to.
      rs_result-found = abap_true.
      APPEND iv_from TO rs_result-path.
      RETURN.
    ENDIF.

    " Dijkstra: repeatedly take the closest unvisited node and relax its arcs.
    lv_guard = lines( lt_dist ) + 1.
    WHILE lv_guard > 0.
      lv_guard = lv_guard - 1.

      CLEAR ls_cur.
      lv_best = c_inf.

      LOOP AT lt_dist INTO ls_row.
        IF ls_row-visited = abap_true OR ls_row-distance >= lv_best.
          CONTINUE.
        ENDIF.

        ls_cur = ls_row.
        lv_best = ls_row-distance.
      ENDLOOP.

      IF lv_best >= c_inf OR ls_cur-node_id = iv_to.
        EXIT.
      ENDIF.

      lt_dist = mark_visited( it_dist = lt_dist iv_node = ls_cur-node_id ).

      LOOP AT it_arcs INTO ls_arc.
        IF ls_arc-from_node <> ls_cur-node_id.
          CONTINUE.
        ENDIF.

        READ TABLE lt_dist INTO ls_row WITH KEY node_id = ls_arc-to_node.
        IF sy-subrc <> 0 OR ls_row-visited = abap_true.
          CONTINUE.
        ENDIF.

        lv_alt = ls_cur-distance + ls_arc-distance.
        IF lv_alt < ls_row-distance.
          lt_dist = set_dist( it_dist     = lt_dist
                              iv_node     = ls_arc-to_node
                              iv_distance = lv_alt
                              iv_prev     = ls_cur-node_id ).
        ENDIF.
      ENDLOOP.
    ENDWHILE.

    READ TABLE lt_dist INTO ls_row WITH KEY node_id = iv_to.
    IF sy-subrc <> 0 OR ls_row-distance >= c_inf.
      RETURN.
    ENDIF.

    rs_result-found = abap_true.
    rs_result-distance = ls_row-distance.

    " Walk the predecessor chain back and reverse it into the result.
    lv_cur = iv_to.
    lv_pos = 0.
    WHILE lv_pos < c_max_hop.
      lv_pos = lv_pos + 1.
      APPEND lv_cur TO lt_rev.

      IF lv_cur = iv_from.
        EXIT.
      ENDIF.

      READ TABLE lt_dist INTO ls_row WITH KEY node_id = lv_cur.
      IF sy-subrc <> 0 OR ls_row-prev IS INITIAL.
        EXIT.
      ENDIF.

      lv_cur = ls_row-prev.
    ENDWHILE.

    lv_pos = lines( lt_rev ).
    WHILE lv_pos >= 1.
      READ TABLE lt_rev INTO lv_id INDEX lv_pos.
      APPEND lv_id TO rs_result-path.
      lv_pos = lv_pos - 1.
    ENDWHILE.

    rs_result-hops = lines( rs_result-path ) - 1.
  ENDMETHOD.

ENDCLASS.
