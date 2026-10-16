CLASS zcl_alloc_return_top DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_item,
             material TYPE matnr,
             quantity TYPE i,
           END OF ty_item.
    TYPES ty_item_tt TYPE STANDARD TABLE OF ty_item WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_top,
             material TYPE matnr,
             quantity TYPE i,
           END OF ty_top.
    TYPES ty_top_tt TYPE STANDARD TABLE OF ty_top WITH DEFAULT KEY.

    METHODS top
      IMPORTING
        it_items      TYPE ty_item_tt
        iv_limit      TYPE i
      RETURNING
        VALUE(rt_top) TYPE ty_top_tt.

    METHODS quantity_of
      IMPORTING
        it_items      TYPE ty_item_tt
        iv_material   TYPE matnr
      RETURNING
        VALUE(rv_qty) TYPE i.

    METHODS count
      IMPORTING
        it_top          TYPE ty_top_tt
      RETURNING
        VALUE(rv_count) TYPE i.

  PRIVATE SECTION.
    TYPES: BEGIN OF ty_work,
             material TYPE matnr,
             quantity TYPE i,
             seq      TYPE i,
           END OF ty_work.
    TYPES ty_work_tt TYPE STANDARD TABLE OF ty_work WITH DEFAULT KEY.

ENDCLASS.


CLASS zcl_alloc_return_top IMPLEMENTATION.

  METHOD top.
    DATA lt_agg  TYPE SORTED TABLE OF ty_top WITH UNIQUE KEY material.
    DATA ls_agg  TYPE ty_top.
    DATA lt_work TYPE ty_work_tt.
    DATA ls_work TYPE ty_work.
    DATA lv_seq  TYPE i.
    DATA ls_top  TYPE ty_top.

    " A non-positive limit asks for no rows.
    IF iv_limit <= 0.
      RETURN.
    ENDIF.

    LOOP AT it_items INTO DATA(ls_item).
      READ TABLE lt_agg ASSIGNING FIELD-SYMBOL(<ls_agg>)
        WITH KEY material = ls_item-material.

      IF sy-subrc <> 0.
        CLEAR ls_agg.
        ls_agg-material = ls_item-material.
        INSERT ls_agg INTO TABLE lt_agg ASSIGNING <ls_agg>.
      ENDIF.

      <ls_agg>-quantity = <ls_agg>-quantity + ls_item-quantity.
    ENDLOOP.

    LOOP AT lt_agg INTO ls_agg.
      lv_seq = lv_seq + 1.

      CLEAR ls_work.
      ls_work-material = ls_agg-material.
      ls_work-quantity = ls_agg-quantity.
      ls_work-seq = lv_seq.
      APPEND ls_work TO lt_work.
    ENDLOOP.

    " Highest quantity first, with the first material seen breaking any tie.
    SORT lt_work BY quantity DESCENDING
                    seq      ASCENDING.

    LOOP AT lt_work INTO ls_work.
      IF lines( rt_top ) >= iv_limit.
        EXIT.
      ENDIF.

      CLEAR ls_top.
      ls_top-material = ls_work-material.
      ls_top-quantity = ls_work-quantity.
      APPEND ls_top TO rt_top.
    ENDLOOP.
  ENDMETHOD.

  METHOD quantity_of.
    LOOP AT it_items INTO DATA(ls_item).
      IF ls_item-material = iv_material.
        rv_qty = rv_qty + ls_item-quantity.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD count.
    rv_count = lines( it_top ).
  ENDMETHOD.

ENDCLASS.
