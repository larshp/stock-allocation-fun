CLASS zcl_alloc_class_summary DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_item,
             material TYPE matnr,
             class    TYPE string,
             value    TYPE i,
           END OF ty_item.
    TYPES ty_item_tt TYPE STANDARD TABLE OF ty_item WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_summary,
             class       TYPE string,
             count       TYPE i,
             total_value TYPE i,
           END OF ty_summary.
    TYPES ty_summary_tt TYPE STANDARD TABLE OF ty_summary WITH DEFAULT KEY.

    METHODS build
      IMPORTING
        it_items          TYPE ty_item_tt
      RETURNING
        VALUE(rt_summary) TYPE ty_summary_tt.

    METHODS count_in
      IMPORTING
        it_items        TYPE ty_item_tt
        iv_class        TYPE string
      RETURNING
        VALUE(rv_count) TYPE i.

    METHODS top_class
      IMPORTING
        it_items        TYPE ty_item_tt
      RETURNING
        VALUE(rv_class) TYPE string.

ENDCLASS.


CLASS zcl_alloc_class_summary IMPLEMENTATION.

  METHOD build.
    DATA lt_summary TYPE SORTED TABLE OF ty_summary WITH UNIQUE KEY class.
    DATA ls_summary TYPE ty_summary.

    " The items are summed per class in a sorted table, so the classes come out
    " in order.
    LOOP AT it_items INTO DATA(ls_item).
      READ TABLE lt_summary ASSIGNING FIELD-SYMBOL(<ls_summary>)
        WITH KEY class = ls_item-class.

      IF sy-subrc <> 0.
        CLEAR ls_summary.
        ls_summary-class = ls_item-class.
        INSERT ls_summary INTO TABLE lt_summary ASSIGNING <ls_summary>.
      ENDIF.

      <ls_summary>-count = <ls_summary>-count + 1.
      <ls_summary>-total_value = <ls_summary>-total_value + ls_item-value.
    ENDLOOP.

    rt_summary = lt_summary.
  ENDMETHOD.

  METHOD count_in.
    LOOP AT it_items INTO DATA(ls_item).
      IF ls_item-class = iv_class.
        rv_count = rv_count + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD top_class.
    DATA lt_summary TYPE ty_summary_tt.
    DATA lv_best    TYPE i.
    DATA lv_found   TYPE abap_bool.

    lt_summary = build( it_items ).

    " The top class carries the highest total value; the first wins ties.
    LOOP AT lt_summary INTO DATA(ls_summary).
      IF lv_found = abap_false OR ls_summary-total_value > lv_best.
        lv_found = abap_true.
        lv_best = ls_summary-total_value.
        rv_class = ls_summary-class.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
