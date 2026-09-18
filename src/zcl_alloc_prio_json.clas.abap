CLASS zcl_alloc_prio_json DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_item,
             requirement_id TYPE zcl_stock_allocator=>ty_result-requirement_id,
             factors        TYPE zcl_alloc_priority=>ty_factors,
           END OF ty_item.
    TYPES ty_item_tt TYPE STANDARD TABLE OF ty_item WITH DEFAULT KEY.

    METHODS constructor.

    METHODS build
      IMPORTING
        it_items       TYPE ty_item_tt
      RETURNING
        VALUE(rv_json) TYPE string.

  PRIVATE SECTION.
    DATA mo_prio TYPE REF TO zcl_alloc_priority.

ENDCLASS.


CLASS zcl_alloc_prio_json IMPLEMENTATION.

  METHOD constructor.
    mo_prio = NEW zcl_alloc_priority( ).
  ENDMETHOD.

  METHOD build.
    DATA lv_item  TYPE string.
    DATA lv_first TYPE abap_bool.
    DATA lv_score TYPE i.

    rv_json = '['.
    lv_first = abap_true.

    LOOP AT it_items INTO DATA(ls_item).
      IF lv_first = abap_false.
        rv_json = rv_json && ','.
      ENDIF.
      lv_first = abap_false.

      lv_score = mo_prio->score( is_factors = ls_item-factors ).

      CLEAR lv_item.
      lv_item = '{'.
      lv_item = lv_item && |"requirement_id":"{ ls_item-requirement_id }",|.
      lv_item = lv_item && |"delivery_priority":{ ls_item-factors-delivery_priority },|.
      lv_item = lv_item && |"days_until_due":{ ls_item-factors-days_until_due },|.
      lv_item = lv_item && |"customer_weight":{ ls_item-factors-customer_weight },|.
      lv_item = lv_item && |"score":{ lv_score }|.
      lv_item = lv_item && '}'.

      rv_json = rv_json && lv_item.
    ENDLOOP.

    rv_json = rv_json && ']'.
  ENDMETHOD.

ENDCLASS.
