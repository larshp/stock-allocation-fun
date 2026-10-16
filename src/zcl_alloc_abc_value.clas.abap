CLASS zcl_alloc_abc_value DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_item,
             material TYPE matnr,
             value    TYPE i,
           END OF ty_item.
    TYPES ty_item_tt TYPE STANDARD TABLE OF ty_item WITH DEFAULT KEY.

    METHODS value_share
      IMPORTING
        it_items        TYPE ty_item_tt
        iv_material     TYPE matnr
      RETURNING
        VALUE(rv_share) TYPE i.

    METHODS classify
      IMPORTING
        iv_value_share  TYPE i
      RETURNING
        VALUE(rv_class) TYPE string.

    METHODS class_at
      IMPORTING
        it_items        TYPE ty_item_tt
        iv_material     TYPE matnr
      RETURNING
        VALUE(rv_class) TYPE string.

  PRIVATE SECTION.
    METHODS total_value
      IMPORTING
        it_items        TYPE ty_item_tt
      RETURNING
        VALUE(rv_total) TYPE i.

ENDCLASS.


CLASS zcl_alloc_abc_value IMPLEMENTATION.

  METHOD total_value.
    LOOP AT it_items INTO DATA(ls_item).
      rv_total = rv_total + ls_item-value.
    ENDLOOP.
  ENDMETHOD.

  METHOD value_share.
    DATA lv_total TYPE i.
    DATA lv_value TYPE i.

    lv_total = total_value( it_items ).
    IF lv_total <= 0.
      RETURN.
    ENDIF.

    LOOP AT it_items INTO DATA(ls_item).
      IF ls_item-material = iv_material.
        lv_value = ls_item-value.
        EXIT.
      ENDIF.
    ENDLOOP.

    rv_share = lv_value * 100 DIV lv_total.
  ENDMETHOD.

  METHOD classify.
    " A single item is vital above half the value, notable above a fifth.
    IF iv_value_share >= 50.
      rv_class = 'A'.
    ELSEIF iv_value_share >= 20.
      rv_class = 'B'.
    ELSE.
      rv_class = 'C'.
    ENDIF.
  ENDMETHOD.

  METHOD class_at.
    DATA lv_share TYPE i.

    lv_share = value_share( it_items = it_items iv_material = iv_material ).
    rv_class = classify( lv_share ).
  ENDMETHOD.

ENDCLASS.
