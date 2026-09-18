CLASS zcl_alloc_route DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_stop,
             stop_id  TYPE string,
             sequence TYPE i,
           END OF ty_stop.
    TYPES ty_stop_tt TYPE STANDARD TABLE OF ty_stop WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_result,
             stops    TYPE ty_stop_tt,
             distance TYPE i,
             legs     TYPE i,
           END OF ty_result.

    METHODS build
      IMPORTING
        it_stops         TYPE ty_stop_tt
        it_arcs          TYPE zcl_alloc_path=>ty_arc_tt
      RETURNING
        VALUE(rs_result) TYPE ty_result.

    METHODS distance_between
      IMPORTING
        it_arcs        TYPE zcl_alloc_path=>ty_arc_tt
        iv_from        TYPE string
        iv_to          TYPE string
      RETURNING
        VALUE(rv_dist) TYPE i.

ENDCLASS.


CLASS zcl_alloc_route IMPLEMENTATION.

  METHOD distance_between.
    READ TABLE it_arcs INTO DATA(ls_arc)
      WITH KEY from_node = iv_from to_node = iv_to.

    IF sy-subrc = 0.
      rv_dist = ls_arc-distance.
    ENDIF.
  ENDMETHOD.

  METHOD build.
    DATA lt_sorted TYPE ty_stop_tt.
    DATA ls_stop   TYPE ty_stop.
    DATA lv_prev   TYPE string.
    DATA lv_leg    TYPE i.
    DATA lv_count  TYPE i.
    DATA lv_pos    TYPE i.

    lt_sorted = it_stops.
    SORT lt_sorted BY sequence ASCENDING.
    rs_result-stops = lt_sorted.

    lv_count = lines( lt_sorted ).

    WHILE lv_pos < lv_count.
      lv_pos = lv_pos + 1.

      READ TABLE lt_sorted INTO ls_stop INDEX lv_pos.

      IF lv_pos > 1.
        lv_leg = distance_between( it_arcs = it_arcs
                                   iv_from = lv_prev
                                   iv_to   = ls_stop-stop_id ).
        rs_result-distance = rs_result-distance + lv_leg.
        rs_result-legs = rs_result-legs + 1.
      ENDIF.

      lv_prev = ls_stop-stop_id.
    ENDWHILE.
  ENDMETHOD.

ENDCLASS.
