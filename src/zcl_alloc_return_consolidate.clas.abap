CLASS zcl_alloc_return_consolidate DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_item,
             group_key TYPE string,
             quantity  TYPE i,
           END OF ty_item.
    TYPES ty_item_tt TYPE STANDARD TABLE OF ty_item WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_group,
             group_key TYPE string,
             quantity  TYPE i,
           END OF ty_group.
    TYPES ty_group_tt TYPE STANDARD TABLE OF ty_group WITH DEFAULT KEY.

    METHODS merge
      IMPORTING
        it_items         TYPE ty_item_tt
      RETURNING
        VALUE(rt_groups) TYPE ty_group_tt.

    METHODS groups
      IMPORTING
        it_groups       TYPE ty_group_tt
      RETURNING
        VALUE(rv_count) TYPE i.

    METHODS largest_group
      IMPORTING
        it_groups       TYPE ty_group_tt
      RETURNING
        VALUE(rv_group) TYPE string.

ENDCLASS.


CLASS zcl_alloc_return_consolidate IMPLEMENTATION.

  METHOD merge.
    DATA lt_count TYPE SORTED TABLE OF ty_group WITH UNIQUE KEY group_key.
    DATA ls_count TYPE ty_group.

    " Returns heading to the same place are merged into one shipment group; the
    " groups come out in key order.
    LOOP AT it_items INTO DATA(ls_item).
      READ TABLE lt_count ASSIGNING FIELD-SYMBOL(<ls_count>)
        WITH KEY group_key = ls_item-group_key.

      IF sy-subrc <> 0.
        CLEAR ls_count.
        ls_count-group_key = ls_item-group_key.
        INSERT ls_count INTO TABLE lt_count ASSIGNING <ls_count>.
      ENDIF.

      <ls_count>-quantity = <ls_count>-quantity + ls_item-quantity.
    ENDLOOP.

    rt_groups = lt_count.
  ENDMETHOD.

  METHOD groups.
    rv_count = lines( it_groups ).
  ENDMETHOD.

  METHOD largest_group.
    DATA lv_best  TYPE i.
    DATA lv_found TYPE abap_bool.

    LOOP AT it_groups INTO DATA(ls_group).
      IF lv_found = abap_false OR ls_group-quantity > lv_best.
        lv_found = abap_true.
        lv_best = ls_group-quantity.
        rv_group = ls_group-group_key.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
