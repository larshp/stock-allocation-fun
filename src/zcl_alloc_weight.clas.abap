CLASS zcl_alloc_weight DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_item,
             factor TYPE i,
             weight TYPE i,
           END OF ty_item.
    TYPES ty_item_tt TYPE STANDARD TABLE OF ty_item WITH DEFAULT KEY.

    METHODS score
      IMPORTING
        it_items        TYPE ty_item_tt
      RETURNING
        VALUE(rv_score) TYPE i.

ENDCLASS.


CLASS zcl_alloc_weight IMPLEMENTATION.

  METHOD score.
    DATA lv_sum    TYPE i.
    DATA lv_weight TYPE i.

    LOOP AT it_items INTO DATA(ls_item).
      lv_sum = lv_sum + ls_item-factor * ls_item-weight.
      lv_weight = lv_weight + ls_item-weight.
    ENDLOOP.

    IF lv_weight > 0.
      rv_score = lv_sum DIV lv_weight.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
