CLASS zcl_alloc_diff3 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_id TYPE c LENGTH 20.

    TYPES: BEGIN OF ty_item,
             id       TYPE ty_id,
             quantity TYPE menge_d,
           END OF ty_item.
    TYPES ty_item_tt TYPE STANDARD TABLE OF ty_item WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_line,
             id        TYPE ty_id,
             base_qty  TYPE menge_d,
             left_qty  TYPE menge_d,
             right_qty TYPE menge_d,
             status    TYPE c LENGTH 1,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_key,
             id TYPE ty_id,
           END OF ty_key.
    TYPES ty_key_tt TYPE STANDARD TABLE OF ty_key WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_input,
             base  TYPE ty_item_tt,
             left  TYPE ty_item_tt,
             right TYPE ty_item_tt,
           END OF ty_input.

    METHODS compare
      IMPORTING
        is_input        TYPE ty_input
      RETURNING
        VALUE(rt_lines) TYPE ty_line_tt.

  PRIVATE SECTION.
    METHODS add_keys
      IMPORTING
        it_items       TYPE ty_item_tt
        it_keys        TYPE ty_key_tt
      RETURNING
        VALUE(rt_keys) TYPE ty_key_tt.

    METHODS qty_of
      IMPORTING
        it_items      TYPE ty_item_tt
        iv_id         TYPE ty_id
      RETURNING
        VALUE(rv_qty) TYPE menge_d.

ENDCLASS.


CLASS zcl_alloc_diff3 IMPLEMENTATION.

  METHOD add_keys.
    rt_keys = it_keys.

    LOOP AT it_items INTO DATA(ls_item).
      READ TABLE rt_keys TRANSPORTING NO FIELDS
        WITH KEY id = ls_item-id.
      IF sy-subrc <> 0.
        APPEND VALUE #( id = ls_item-id ) TO rt_keys.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD qty_of.
    READ TABLE it_items INTO DATA(ls_item)
      WITH KEY id = iv_id.
    IF sy-subrc = 0.
      rv_qty = ls_item-quantity.
    ENDIF.
  ENDMETHOD.

  METHOD compare.
    DATA lt_keys TYPE ty_key_tt.
    DATA ls_line TYPE ty_line.

    lt_keys = add_keys( it_items = is_input-base
                        it_keys  = lt_keys ).
    lt_keys = add_keys( it_items = is_input-left
                        it_keys  = lt_keys ).
    lt_keys = add_keys( it_items = is_input-right
                        it_keys  = lt_keys ).

    SORT lt_keys BY id ASCENDING.

    LOOP AT lt_keys INTO DATA(ls_key).
      CLEAR ls_line.
      ls_line-id = ls_key-id.
      ls_line-base_qty = qty_of( it_items = is_input-base
                                 iv_id    = ls_key-id ).
      ls_line-left_qty = qty_of( it_items = is_input-left
                                 iv_id    = ls_key-id ).
      ls_line-right_qty = qty_of( it_items = is_input-right
                                  iv_id    = ls_key-id ).

      IF ls_line-left_qty = ls_line-right_qty.
        ls_line-status = 'S'.
      ELSEIF ls_line-right_qty = ls_line-base_qty.
        ls_line-status = 'L'.
      ELSEIF ls_line-left_qty = ls_line-base_qty.
        ls_line-status = 'R'.
      ELSE.
        ls_line-status = 'C'.
      ENDIF.

      APPEND ls_line TO rt_lines.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
