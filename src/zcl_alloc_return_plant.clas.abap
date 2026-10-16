CLASS zcl_alloc_return_plant DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_item,
             plant    TYPE string,
             quantity TYPE i,
           END OF ty_item.
    TYPES ty_item_tt TYPE STANDARD TABLE OF ty_item WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_group,
             plant    TYPE string,
             quantity TYPE i,
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

    METHODS top_plant
      IMPORTING
        it_items        TYPE ty_item_tt
      RETURNING
        VALUE(rv_plant) TYPE string.

ENDCLASS.


CLASS zcl_alloc_return_plant IMPLEMENTATION.

  METHOD group.
    DATA lt_count TYPE SORTED TABLE OF ty_group WITH UNIQUE KEY plant.
    DATA ls_count TYPE ty_group.

    " Quantities are summed per plant in a sorted table, so the output is already
    " in plant order.
    LOOP AT it_items INTO DATA(ls_item).
      READ TABLE lt_count ASSIGNING FIELD-SYMBOL(<ls_count>)
        WITH KEY plant = ls_item-plant.

      IF sy-subrc <> 0.
        CLEAR ls_count.
        ls_count-plant = ls_item-plant.
        INSERT ls_count INTO TABLE lt_count ASSIGNING <ls_count>.
      ENDIF.

      <ls_count>-quantity = <ls_count>-quantity + ls_item-quantity.
    ENDLOOP.

    rt_groups = lt_count.
  ENDMETHOD.

  METHOD total.
    LOOP AT it_items INTO DATA(ls_item).
      rv_total = rv_total + ls_item-quantity.
    ENDLOOP.
  ENDMETHOD.

  METHOD top_plant.
    DATA lv_best  TYPE i.
    DATA lv_found TYPE abap_bool.

    LOOP AT it_items INTO DATA(ls_item).
      IF lv_found = abap_false OR ls_item-quantity > lv_best.
        lv_found = abap_true.
        lv_best = ls_item-quantity.
        rv_plant = ls_item-plant.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
