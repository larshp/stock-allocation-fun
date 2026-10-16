CLASS zcl_alloc_replenish_prioritize DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             material TYPE matnr,
             priority TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    METHODS ordered
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rt_lines) TYPE ty_line_tt.

    METHODS line_count
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rv_count) TYPE i.

    METHODS first_material
      IMPORTING
        it_lines           TYPE ty_line_tt
      RETURNING
        VALUE(rv_material) TYPE matnr.

  PRIVATE SECTION.
    TYPES: BEGIN OF ty_work,
             material TYPE matnr,
             priority TYPE i,
             seq      TYPE i,
           END OF ty_work.

ENDCLASS.


CLASS zcl_alloc_replenish_prioritize IMPLEMENTATION.

  METHOD ordered.
    DATA lt_work TYPE STANDARD TABLE OF ty_work WITH DEFAULT KEY.
    DATA ls_work TYPE ty_work.
    DATA ls_out  TYPE ty_line.
    DATA lv_seq  TYPE i.

    " The lines are carried with their position, so equal priorities keep
    " their original order once sorted by priority.
    LOOP AT it_lines INTO DATA(ls_line).
      lv_seq = lv_seq + 1.
      ls_work-material = ls_line-material.
      ls_work-priority = ls_line-priority.
      ls_work-seq = lv_seq.
      APPEND ls_work TO lt_work.
    ENDLOOP.

    SORT lt_work BY priority DESCENDING seq ASCENDING.

    LOOP AT lt_work INTO ls_work.
      ls_out-material = ls_work-material.
      ls_out-priority = ls_work-priority.
      APPEND ls_out TO rt_lines.
    ENDLOOP.
  ENDMETHOD.

  METHOD line_count.
    rv_count = lines( it_lines ).
  ENDMETHOD.

  METHOD first_material.
    DATA lt_sorted TYPE ty_line_tt.
    DATA ls_line   TYPE ty_line.

    " The first of the ordered lines carries the highest priority.
    lt_sorted = ordered( it_lines ).

    READ TABLE lt_sorted INTO ls_line INDEX 1.
    IF sy-subrc = 0.
      rv_material = ls_line-material.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
