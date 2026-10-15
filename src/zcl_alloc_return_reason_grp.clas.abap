CLASS zcl_alloc_return_reason_grp DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_item,
             reason   TYPE string,
             quantity TYPE menge_d,
           END OF ty_item.
    TYPES ty_item_tt TYPE STANDARD TABLE OF ty_item WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_group,
             reason     TYPE string,
             quantity   TYPE menge_d,
             line_count TYPE i,
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
        VALUE(rv_total) TYPE menge_d.

ENDCLASS.


CLASS zcl_alloc_return_reason_grp IMPLEMENTATION.

  METHOD group.
    DATA lt_group TYPE SORTED TABLE OF ty_group WITH UNIQUE KEY reason.
    DATA ls_group TYPE ty_group.

    " A sorted table keyed by reason keeps the grouping logarithmic per item and
    " the output ordered by reason, without rescanning the input per reason.
    LOOP AT it_items INTO DATA(ls_item).
      READ TABLE lt_group ASSIGNING FIELD-SYMBOL(<ls_group>)
        WITH KEY reason = ls_item-reason.

      IF sy-subrc <> 0.
        CLEAR ls_group.
        ls_group-reason = ls_item-reason.
        INSERT ls_group INTO TABLE lt_group ASSIGNING <ls_group>.
      ENDIF.

      <ls_group>-quantity = <ls_group>-quantity + ls_item-quantity.
      <ls_group>-line_count = <ls_group>-line_count + 1.
    ENDLOOP.

    rt_groups = lt_group.
  ENDMETHOD.

  METHOD total.
    LOOP AT it_items INTO DATA(ls_item).
      rv_total = rv_total + ls_item-quantity.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
