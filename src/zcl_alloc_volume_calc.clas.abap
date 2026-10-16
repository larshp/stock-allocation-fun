CLASS zcl_alloc_volume_calc DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_dim,
             len TYPE i,
             wid TYPE i,
             hgt TYPE i,
           END OF ty_dim.

    TYPES: BEGIN OF ty_item,
             dim      TYPE ty_dim,
             quantity TYPE i,
           END OF ty_item.
    TYPES ty_item_tt TYPE STANDARD TABLE OF ty_item WITH DEFAULT KEY.

    METHODS volume_of
      IMPORTING
        is_dim           TYPE ty_dim
      RETURNING
        VALUE(rv_volume) TYPE i.

    METHODS total_volume
      IMPORTING
        it_items         TYPE ty_item_tt
      RETURNING
        VALUE(rv_volume) TYPE i.

ENDCLASS.


CLASS zcl_alloc_volume_calc IMPLEMENTATION.

  METHOD volume_of.
    IF is_dim-len <= 0 OR is_dim-wid <= 0 OR is_dim-hgt <= 0.
      RETURN.
    ENDIF.

    rv_volume = is_dim-len * is_dim-wid * is_dim-hgt.
  ENDMETHOD.

  METHOD total_volume.
    DATA lv_one TYPE i.

    LOOP AT it_items INTO DATA(ls_item).
      IF ls_item-quantity <= 0.
        CONTINUE.
      ENDIF.

      lv_one = volume_of( is_dim = ls_item-dim ).
      rv_volume = rv_volume + lv_one * ls_item-quantity.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
