CLASS zcl_alloc_return_daily DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_item,
             day   TYPE d,
             count TYPE i,
           END OF ty_item.
    TYPES ty_item_tt TYPE STANDARD TABLE OF ty_item WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_group,
             day   TYPE d,
             count TYPE i,
           END OF ty_group.
    TYPES ty_group_tt TYPE STANDARD TABLE OF ty_group WITH DEFAULT KEY.

    METHODS group
      IMPORTING
        it_items         TYPE ty_item_tt
      RETURNING
        VALUE(rt_groups) TYPE ty_group_tt.

    METHODS total
      IMPORTING
        it_items        TYPE ty_item_tt
      RETURNING
        VALUE(rv_total) TYPE i.

    METHODS busiest_day
      IMPORTING
        it_items      TYPE ty_item_tt
      RETURNING
        VALUE(rv_day) TYPE d.

ENDCLASS.


CLASS zcl_alloc_return_daily IMPLEMENTATION.

  METHOD group.
    DATA lt_count TYPE SORTED TABLE OF ty_group WITH UNIQUE KEY day.
    DATA ls_count TYPE ty_group.

    " Counts are summed per day in a sorted table, so the output is already in
    " date order.
    LOOP AT it_items INTO DATA(ls_item).
      READ TABLE lt_count ASSIGNING FIELD-SYMBOL(<ls_count>)
        WITH KEY day = ls_item-day.

      IF sy-subrc <> 0.
        CLEAR ls_count.
        ls_count-day = ls_item-day.
        INSERT ls_count INTO TABLE lt_count ASSIGNING <ls_count>.
      ENDIF.

      <ls_count>-count = <ls_count>-count + ls_item-count.
    ENDLOOP.

    rt_groups = lt_count.
  ENDMETHOD.

  METHOD total.
    LOOP AT it_items INTO DATA(ls_item).
      rv_total = rv_total + ls_item-count.
    ENDLOOP.
  ENDMETHOD.

  METHOD busiest_day.
    DATA lv_best  TYPE i.
    DATA lv_found TYPE abap_bool.

    " The day with the most returns; an empty input leaves the date initial.
    LOOP AT it_items INTO DATA(ls_item).
      IF lv_found = abap_false OR ls_item-count > lv_best.
        lv_found = abap_true.
        lv_best = ls_item-count.
        rv_day = ls_item-day.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
