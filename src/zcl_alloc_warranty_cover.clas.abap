CLASS zcl_alloc_warranty_cover DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_item,
             material  TYPE matnr,
             start_day TYPE d,
             days      TYPE i,
             quantity  TYPE menge_d,
           END OF ty_item.
    TYPES ty_item_tt TYPE STANDARD TABLE OF ty_item WITH DEFAULT KEY.

    METHODS cover
      IMPORTING
        it_items        TYPE ty_item_tt
        iv_check_day    TYPE d
      RETURNING
        VALUE(rv_count) TYPE i.

    METHODS covered_quantity
      IMPORTING
        it_items        TYPE ty_item_tt
        iv_check_day    TYPE d
      RETURNING
        VALUE(rv_total) TYPE menge_d.

    METHODS share_percent
      IMPORTING
        iv_covered    TYPE i
        iv_total      TYPE i
      RETURNING
        VALUE(rv_pct) TYPE i.

  PRIVATE SECTION.
    METHODS is_covered
      IMPORTING
        is_item      TYPE ty_item
        iv_check_day TYPE d
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_warranty_cover IMPLEMENTATION.

  METHOD is_covered.
    DATA ls_warranty TYPE zcl_alloc_warranty_check=>ty_warranty.
    DATA lo_check    TYPE REF TO zcl_alloc_warranty_check.

    ls_warranty-material = is_item-material.
    ls_warranty-start_day = is_item-start_day.
    ls_warranty-days = is_item-days.

    lo_check = NEW zcl_alloc_warranty_check( ).
    rv_ok = lo_check->is_covered( is_warranty  = ls_warranty
                                  iv_check_day = iv_check_day ).
  ENDMETHOD.

  METHOD cover.
    LOOP AT it_items INTO DATA(ls_item).
      IF is_covered( is_item      = ls_item
                     iv_check_day = iv_check_day ) = abap_true.
        rv_count = rv_count + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD covered_quantity.
    LOOP AT it_items INTO DATA(ls_item).
      IF is_covered( is_item      = ls_item
                     iv_check_day = iv_check_day ) = abap_true.
        rv_total = rv_total + ls_item-quantity.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD share_percent.
    IF iv_total <= 0 OR iv_covered <= 0.
      RETURN.
    ENDIF.

    rv_pct = iv_covered * 100 DIV iv_total.
  ENDMETHOD.

ENDCLASS.
