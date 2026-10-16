CLASS zcl_alloc_hu DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_item,
             material TYPE matnr,
             quantity TYPE menge_d,
           END OF ty_item.
    TYPES ty_item_tt TYPE STANDARD TABLE OF ty_item WITH DEFAULT KEY.

    METHODS add
      IMPORTING
        is_item TYPE ty_item.

    METHODS total
      RETURNING
        VALUE(rv_total) TYPE menge_d.

    METHODS item_count
      RETURNING
        VALUE(rv_count) TYPE i.

    METHODS material_count
      RETURNING
        VALUE(rv_count) TYPE i.

    METHODS items
      RETURNING
        VALUE(rt_items) TYPE ty_item_tt.

    METHODS clear.

  PRIVATE SECTION.
    DATA mt_items TYPE ty_item_tt.

ENDCLASS.


CLASS zcl_alloc_hu IMPLEMENTATION.

  METHOD add.
    APPEND is_item TO mt_items.
  ENDMETHOD.

  METHOD total.
    LOOP AT mt_items INTO DATA(ls_item).
      rv_total = rv_total + ls_item-quantity.
    ENDLOOP.
  ENDMETHOD.

  METHOD item_count.
    rv_count = lines( mt_items ).
  ENDMETHOD.

  METHOD material_count.
    DATA lo_seen TYPE REF TO zcl_alloc_key_map.
    DATA lv_key  TYPE string.

    " A map counts the distinct materials in one pass, so a handling unit with
    " many items does not rescan the item list per material.
    lo_seen = NEW zcl_alloc_key_map( ).

    LOOP AT mt_items INTO DATA(ls_item).
      lv_key = ls_item-material.
      lo_seen->put( iv_key   = lv_key
                    iv_value = 0 ).
    ENDLOOP.

    rv_count = lo_seen->size( ).
  ENDMETHOD.

  METHOD items.
    rt_items = mt_items.
  ENDMETHOD.

  METHOD clear.
    CLEAR mt_items.
  ENDMETHOD.

ENDCLASS.
