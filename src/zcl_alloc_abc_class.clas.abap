CLASS zcl_alloc_abc_class DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_item,
             material TYPE matnr,
             value    TYPE i,
             class    TYPE string,
           END OF ty_item.
    TYPES ty_item_tt TYPE STANDARD TABLE OF ty_item WITH DEFAULT KEY.

    METHODS classify
      IMPORTING
        it_items        TYPE ty_item_tt
      RETURNING
        VALUE(rt_items) TYPE ty_item_tt.

    METHODS class_of
      IMPORTING
        it_items        TYPE ty_item_tt
        iv_material     TYPE matnr
      RETURNING
        VALUE(rv_class) TYPE string.

    METHODS count_in
      IMPORTING
        it_items        TYPE ty_item_tt
        iv_class        TYPE string
      RETURNING
        VALUE(rv_count) TYPE i.

  PRIVATE SECTION.
    TYPES: BEGIN OF ty_work,
             material TYPE matnr,
             value    TYPE i,
             seq      TYPE i,
           END OF ty_work.

    METHODS total_value
      IMPORTING
        it_items        TYPE ty_item_tt
      RETURNING
        VALUE(rv_total) TYPE i.

ENDCLASS.


CLASS zcl_alloc_abc_class IMPLEMENTATION.

  METHOD total_value.
    LOOP AT it_items INTO DATA(ls_item).
      rv_total = rv_total + ls_item-value.
    ENDLOOP.
  ENDMETHOD.

  METHOD classify.
    DATA lv_total      TYPE i.
    DATA lt_work       TYPE STANDARD TABLE OF ty_work WITH DEFAULT KEY.
    DATA ls_work       TYPE ty_work.
    DATA ls_out        TYPE ty_item.
    DATA lv_seq        TYPE i.
    DATA lv_cumulative TYPE i.
    DATA lv_share      TYPE i.

    lv_total = total_value( it_items ).
    IF lv_total <= 0.
      RETURN.
    ENDIF.

    " The items are carried with their position, so equal values keep their
    " original order once sorted by value.
    LOOP AT it_items INTO DATA(ls_item).
      lv_seq = lv_seq + 1.
      ls_work-material = ls_item-material.
      ls_work-value = ls_item-value.
      ls_work-seq = lv_seq.
      APPEND ls_work TO lt_work.
    ENDLOOP.

    SORT lt_work BY value DESCENDING seq ASCENDING.

    " The class follows the running share of the total value: the vital few
    " reach eighty percent, the next tier fifteen, the rest the tail.
    LOOP AT lt_work INTO ls_work.
      lv_cumulative = lv_cumulative + ls_work-value.
      lv_share = lv_cumulative * 100 DIV lv_total.

      ls_out-material = ls_work-material.
      ls_out-value = ls_work-value.
      IF lv_share <= 80.
        ls_out-class = 'A'.
      ELSEIF lv_share <= 95.
        ls_out-class = 'B'.
      ELSE.
        ls_out-class = 'C'.
      ENDIF.
      APPEND ls_out TO rt_items.
    ENDLOOP.
  ENDMETHOD.

  METHOD class_of.
    LOOP AT it_items INTO DATA(ls_item).
      IF ls_item-material = iv_material.
        rv_class = ls_item-class.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD count_in.
    LOOP AT it_items INTO DATA(ls_item).
      IF ls_item-class = iv_class.
        rv_count = rv_count + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
