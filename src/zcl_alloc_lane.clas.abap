CLASS zcl_alloc_lane DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_lane,
             from_node   TYPE string,
             to_node     TYPE string,
             distance    TYPE i,
             cost_per_km TYPE menge_d,
           END OF ty_lane.
    TYPES ty_lane_tt TYPE STANDARD TABLE OF ty_lane WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_cell,
             from_node TYPE string,
             to_node   TYPE string,
             distance  TYPE i,
             cost      TYPE menge_d,
           END OF ty_cell.
    TYPES ty_cell_tt TYPE STANDARD TABLE OF ty_cell WITH DEFAULT KEY.

    METHODS build
      IMPORTING
        it_lanes        TYPE ty_lane_tt
      RETURNING
        VALUE(rt_cells) TYPE ty_cell_tt.

    METHODS cost_of
      IMPORTING
        it_cells       TYPE ty_cell_tt
        iv_from        TYPE string
        iv_to          TYPE string
      RETURNING
        VALUE(rv_cost) TYPE menge_d.

    METHODS cheapest_lane
      IMPORTING
        it_cells       TYPE ty_cell_tt
      RETURNING
        VALUE(rs_cell) TYPE ty_cell.

ENDCLASS.


CLASS zcl_alloc_lane IMPLEMENTATION.

  METHOD build.
    DATA ls_cell TYPE ty_cell.

    LOOP AT it_lanes INTO DATA(ls_lane).
      IF ls_lane-distance <= 0 OR ls_lane-cost_per_km <= 0.
        CONTINUE.
      ENDIF.

      CLEAR ls_cell.
      ls_cell-from_node = ls_lane-from_node.
      ls_cell-to_node = ls_lane-to_node.
      ls_cell-distance = ls_lane-distance.
      ls_cell-cost = ls_lane-distance * ls_lane-cost_per_km.
      APPEND ls_cell TO rt_cells.
    ENDLOOP.
  ENDMETHOD.

  METHOD cost_of.
    READ TABLE it_cells INTO DATA(ls_cell)
      WITH KEY from_node = iv_from to_node = iv_to.

    IF sy-subrc = 0.
      rv_cost = ls_cell-cost.
    ENDIF.
  ENDMETHOD.

  METHOD cheapest_lane.
    DATA lv_best  TYPE menge_d.
    DATA lv_first TYPE abap_bool.

    lv_first = abap_true.

    LOOP AT it_cells INTO DATA(ls_cell).
      IF lv_first = abap_true OR ls_cell-cost < lv_best.
        lv_best = ls_cell-cost.
        rs_cell = ls_cell.
        lv_first = abap_false.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
