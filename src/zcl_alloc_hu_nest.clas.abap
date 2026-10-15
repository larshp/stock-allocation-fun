CLASS zcl_alloc_hu_nest DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_edge,
             hu_id     TYPE string,
             parent_id TYPE string,
           END OF ty_edge.
    TYPES ty_edge_tt TYPE STANDARD TABLE OF ty_edge WITH DEFAULT KEY.
    TYPES ty_ids_tt  TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

    METHODS root_of
      IMPORTING
        it_edges       TYPE ty_edge_tt
        iv_id          TYPE string
      RETURNING
        VALUE(rv_root) TYPE string.

    METHODS depth_of
      IMPORTING
        it_edges        TYPE ty_edge_tt
        iv_id           TYPE string
      RETURNING
        VALUE(rv_depth) TYPE i.

    METHODS children_of
      IMPORTING
        it_edges      TYPE ty_edge_tt
        iv_id         TYPE string
      RETURNING
        VALUE(rt_ids) TYPE ty_ids_tt.

ENDCLASS.


CLASS zcl_alloc_hu_nest IMPLEMENTATION.

  METHOD root_of.
    DATA lv_cur   TYPE string.
    DATA lv_guard TYPE i.

    lv_cur = iv_id.
    lv_guard = lines( it_edges ) + 1.

    " Walking the parents is a straight chain, so the guard is only there to stop
    " a malformed cycle from looping forever.
    WHILE lv_guard > 0.
      lv_guard = lv_guard - 1.

      READ TABLE it_edges INTO DATA(ls_edge) WITH KEY hu_id = lv_cur.
      IF sy-subrc <> 0 OR ls_edge-parent_id IS INITIAL.
        EXIT.
      ENDIF.

      lv_cur = ls_edge-parent_id.
    ENDWHILE.

    rv_root = lv_cur.
  ENDMETHOD.

  METHOD depth_of.
    DATA lv_cur   TYPE string.
    DATA lv_guard TYPE i.

    lv_cur = iv_id.
    lv_guard = lines( it_edges ) + 1.

    WHILE lv_guard > 0.
      lv_guard = lv_guard - 1.

      READ TABLE it_edges INTO DATA(ls_edge) WITH KEY hu_id = lv_cur.
      IF sy-subrc <> 0 OR ls_edge-parent_id IS INITIAL.
        EXIT.
      ENDIF.

      lv_cur = ls_edge-parent_id.
      rv_depth = rv_depth + 1.
    ENDWHILE.
  ENDMETHOD.

  METHOD children_of.
    LOOP AT it_edges INTO DATA(ls_edge).
      IF ls_edge-parent_id = iv_id.
        APPEND ls_edge-hu_id TO rt_ids.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
