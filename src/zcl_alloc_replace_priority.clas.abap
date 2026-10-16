CLASS zcl_alloc_replace_priority DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_item,
             item_id   TYPE string,
             tier      TYPE i,
             wait_days TYPE i,
             value     TYPE i,
           END OF ty_item.
    TYPES ty_item_tt TYPE STANDARD TABLE OF ty_item WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_ranked,
             item_id TYPE string,
             score   TYPE i,
           END OF ty_ranked.
    TYPES ty_ranked_tt TYPE STANDARD TABLE OF ty_ranked WITH DEFAULT KEY.

    METHODS score
      IMPORTING
        iv_tier         TYPE i
        iv_wait_days    TYPE i
        iv_value        TYPE i
      RETURNING
        VALUE(rv_score) TYPE i.

    METHODS rank
      IMPORTING
        it_items         TYPE ty_item_tt
      RETURNING
        VALUE(rt_ranked) TYPE ty_ranked_tt.

    METHODS is_urgent
      IMPORTING
        iv_score     TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

  PRIVATE SECTION.
    TYPES: BEGIN OF ty_work,
             item_id TYPE string,
             score   TYPE i,
             seq     TYPE i,
           END OF ty_work.
    TYPES ty_work_tt TYPE STANDARD TABLE OF ty_work WITH DEFAULT KEY.

ENDCLASS.


CLASS zcl_alloc_replace_priority IMPLEMENTATION.

  METHOD score.
    DATA lv_tier TYPE i.
    DATA lv_wait TYPE i.
    DATA lv_val  TYPE i.

    " A negative input counts as zero, so a bad figure never lowers the score.
    IF iv_tier > 0.
      lv_tier = iv_tier.
    ENDIF.
    IF iv_wait_days > 0.
      lv_wait = iv_wait_days.
    ENDIF.
    IF iv_value > 0.
      lv_val = iv_value.
    ENDIF.

    rv_score = lv_tier * 10 + lv_wait * 2 + lv_val DIV 100.
  ENDMETHOD.

  METHOD rank.
    DATA lt_work  TYPE ty_work_tt.
    DATA ls_work  TYPE ty_work.
    DATA lv_seq   TYPE i.
    DATA ls_ranked TYPE ty_ranked.

    LOOP AT it_items INTO DATA(ls_item).
      CLEAR ls_work.
      lv_seq = lv_seq + 1.
      ls_work-item_id = ls_item-item_id.
      ls_work-score = score( iv_tier      = ls_item-tier
                             iv_wait_days = ls_item-wait_days
                             iv_value     = ls_item-value ).
      ls_work-seq = lv_seq.
      APPEND ls_work TO lt_work.
    ENDLOOP.

    " Highest score first, with the input order breaking any tie.
    SORT lt_work BY score DESCENDING
                    seq   ASCENDING.

    LOOP AT lt_work INTO ls_work.
      CLEAR ls_ranked.
      ls_ranked-item_id = ls_work-item_id.
      ls_ranked-score = ls_work-score.
      APPEND ls_ranked TO rt_ranked.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_urgent.
    rv_ok = xsdbool( iv_score >= 50 ).
  ENDMETHOD.

ENDCLASS.
