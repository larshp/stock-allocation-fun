CLASS zcl_alloc_replenish_priority DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_item,
             material TYPE matnr,
             urgency  TYPE i,
           END OF ty_item.
    TYPES ty_item_tt TYPE STANDARD TABLE OF ty_item WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_rank,
             material TYPE matnr,
             urgency  TYPE i,
             rank     TYPE i,
           END OF ty_rank.
    TYPES ty_rank_tt TYPE STANDARD TABLE OF ty_rank WITH DEFAULT KEY.

    METHODS rank
      IMPORTING
        it_items       TYPE ty_item_tt
      RETURNING
        VALUE(rt_rank) TYPE ty_rank_tt.

    METHODS top
      IMPORTING
        it_items      TYPE ty_item_tt
        iv_limit      TYPE i
      RETURNING
        VALUE(rt_top) TYPE ty_rank_tt.

    METHODS count
      IMPORTING
        it_items        TYPE ty_item_tt
      RETURNING
        VALUE(rv_count) TYPE i.

  PRIVATE SECTION.
    TYPES: BEGIN OF ty_work,
             material TYPE matnr,
             urgency  TYPE i,
             seq      TYPE i,
           END OF ty_work.

ENDCLASS.


CLASS zcl_alloc_replenish_priority IMPLEMENTATION.

  METHOD count.
    rv_count = lines( it_items ).
  ENDMETHOD.

  METHOD rank.
    DATA lt_work TYPE STANDARD TABLE OF ty_work WITH DEFAULT KEY.
    DATA ls_work TYPE ty_work.
    DATA ls_rank TYPE ty_rank.
    DATA lv_seq  TYPE i.
    DATA lv_pos  TYPE i.

    " The items are carried with their position, so equal urgencies keep their
    " original order once sorted by urgency.
    LOOP AT it_items INTO DATA(ls_item).
      lv_seq = lv_seq + 1.
      ls_work-material = ls_item-material.
      ls_work-urgency = ls_item-urgency.
      ls_work-seq = lv_seq.
      APPEND ls_work TO lt_work.
    ENDLOOP.

    SORT lt_work BY urgency DESCENDING seq ASCENDING.

    LOOP AT lt_work INTO ls_work.
      lv_pos = lv_pos + 1.
      ls_rank-material = ls_work-material.
      ls_rank-urgency = ls_work-urgency.
      ls_rank-rank = lv_pos.
      APPEND ls_rank TO rt_rank.
    ENDLOOP.
  ENDMETHOD.

  METHOD top.
    DATA lt_rank TYPE ty_rank_tt.

    lt_rank = rank( it_items ).

    " The top list keeps the highest-urgency entries up to the limit.
    LOOP AT lt_rank INTO DATA(ls_rank).
      IF ls_rank-rank > iv_limit.
        EXIT.
      ENDIF.

      APPEND ls_rank TO rt_top.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
