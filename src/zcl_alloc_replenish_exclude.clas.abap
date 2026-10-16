CLASS zcl_alloc_replenish_exclude DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_item,
             material     TYPE matnr,
             blocked      TYPE abap_bool,
             discontinued TYPE abap_bool,
           END OF ty_item.
    TYPES ty_item_tt TYPE STANDARD TABLE OF ty_item WITH DEFAULT KEY.

    METHODS should_exclude
      IMPORTING
        is_item      TYPE ty_item
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS reason
      IMPORTING
        is_item          TYPE ty_item
      RETURNING
        VALUE(rv_reason) TYPE string.

    METHODS excluded_count
      IMPORTING
        it_items        TYPE ty_item_tt
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_replenish_exclude IMPLEMENTATION.

  METHOD should_exclude.
    " A blocked or discontinued material is kept out of replenishment.
    rv_ok = xsdbool( is_item-blocked = abap_true
                     OR is_item-discontinued = abap_true ).
  ENDMETHOD.

  METHOD reason.
    " The block takes precedence over the discontinuation.
    IF is_item-blocked = abap_true.
      rv_reason = 'BLOCKED'.
    ELSEIF is_item-discontinued = abap_true.
      rv_reason = 'DISCONTINUED'.
    ELSE.
      rv_reason = 'OK'.
    ENDIF.
  ENDMETHOD.

  METHOD excluded_count.
    LOOP AT it_items INTO DATA(ls_item).
      IF should_exclude( ls_item ) = abap_true.
        rv_count = rv_count + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
