CLASS zcl_alloc_swap_opt DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_nodes_tt TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_arc,
             from_node TYPE string,
             to_node   TYPE string,
             cost      TYPE menge_d,
           END OF ty_arc.
    TYPES ty_arc_tt TYPE STANDARD TABLE OF ty_arc WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_result,
             order      TYPE ty_nodes_tt,
             total_cost TYPE menge_d,
             swaps      TYPE i,
           END OF ty_result.

    METHODS improve
      IMPORTING
        it_nodes         TYPE ty_nodes_tt
        it_arcs          TYPE ty_arc_tt
      RETURNING
        VALUE(rs_result) TYPE ty_result.

  PRIVATE SECTION.
    METHODS reverse_between
      IMPORTING
        it_nodes        TYPE ty_nodes_tt
        iv_from         TYPE i
        iv_to           TYPE i
      RETURNING
        VALUE(rt_nodes) TYPE ty_nodes_tt.

    METHODS cost_of_order
      IMPORTING
        it_nodes       TYPE ty_nodes_tt
        it_arcs        TYPE ty_arc_tt
      RETURNING
        VALUE(rv_cost) TYPE menge_d.

ENDCLASS.


CLASS zcl_alloc_swap_opt IMPLEMENTATION.

  METHOD reverse_between.
    DATA lv_count TYPE i.
    DATA lv_i     TYPE i.
    DATA lv_node  TYPE string.

    lv_count = lines( it_nodes ).

    lv_i = 1.
    WHILE lv_i < iv_from.
      READ TABLE it_nodes INTO lv_node INDEX lv_i.
      APPEND lv_node TO rt_nodes.
      lv_i = lv_i + 1.
    ENDWHILE.

    lv_i = iv_to.
    WHILE lv_i >= iv_from.
      READ TABLE it_nodes INTO lv_node INDEX lv_i.
      APPEND lv_node TO rt_nodes.
      lv_i = lv_i - 1.
    ENDWHILE.

    lv_i = iv_to + 1.
    WHILE lv_i <= lv_count.
      READ TABLE it_nodes INTO lv_node INDEX lv_i.
      APPEND lv_node TO rt_nodes.
      lv_i = lv_i + 1.
    ENDWHILE.
  ENDMETHOD.

  METHOD cost_of_order.
    " An arc that is not in the table counts as zero cost, so pass a
    " complete arc table when the comparison should be meaningful.
    DATA lv_count TYPE i.
    DATA lv_i     TYPE i.
    DATA lv_pos   TYPE i.
    DATA lv_from  TYPE string.
    DATA lv_to    TYPE string.

    lv_count = lines( it_nodes ).
    IF lv_count < 2.
      RETURN.
    ENDIF.

    lv_i = 1.
    WHILE lv_i < lv_count.
      lv_pos = lv_i + 1.

      READ TABLE it_nodes INTO lv_from INDEX lv_i.
      READ TABLE it_nodes INTO lv_to INDEX lv_pos.

      READ TABLE it_arcs INTO DATA(ls_arc)
        WITH KEY from_node = lv_from to_node = lv_to.
      IF sy-subrc = 0.
        rv_cost = rv_cost + ls_arc-cost.
      ENDIF.

      lv_i = lv_i + 1.
    ENDWHILE.
  ENDMETHOD.

  METHOD improve.
    DATA lt_cand  TYPE ty_nodes_tt.
    DATA lv_best  TYPE menge_d.
    DATA lv_cost  TYPE menge_d.
    DATA lv_count TYPE i.
    DATA lv_i     TYPE i.
    DATA lv_j     TYPE i.
    DATA lv_pass  TYPE i.
    DATA lv_more  TYPE abap_bool.

    rs_result-order = it_nodes.
    lv_best = cost_of_order( it_nodes = it_nodes
                             it_arcs  = it_arcs ).

    lv_count = lines( it_nodes ).
    IF lv_count < 2.
      rs_result-total_cost = lv_best.
      RETURN.
    ENDIF.

    lv_more = abap_true.
    WHILE lv_more = abap_true AND lv_pass < 20.
      lv_pass = lv_pass + 1.
      lv_more = abap_false.

      lv_i = 1.
      WHILE lv_i < lv_count.
        lv_j = lv_i + 1.

        WHILE lv_j <= lv_count.
          lt_cand = reverse_between( it_nodes = rs_result-order
                                     iv_from  = lv_i
                                     iv_to    = lv_j ).
          lv_cost = cost_of_order( it_nodes = lt_cand
                                   it_arcs  = it_arcs ).

          IF lv_cost < lv_best.
            rs_result-order = lt_cand.
            lv_best = lv_cost.
            rs_result-swaps = rs_result-swaps + 1.
            lv_more = abap_true.
          ENDIF.

          lv_j = lv_j + 1.
        ENDWHILE.

        lv_i = lv_i + 1.
      ENDWHILE.
    ENDWHILE.

    rs_result-total_cost = lv_best.
  ENDMETHOD.

ENDCLASS.
