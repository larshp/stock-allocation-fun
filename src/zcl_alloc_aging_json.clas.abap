CLASS zcl_alloc_aging_json DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_item,
             id           TYPE c LENGTH 20,
             days_overdue TYPE i,
           END OF ty_item.
    TYPES ty_item_tt TYPE STANDARD TABLE OF ty_item WITH DEFAULT KEY.

    METHODS constructor.

    METHODS build
      IMPORTING
        it_items       TYPE ty_item_tt
      RETURNING
        VALUE(rv_json) TYPE string.

  PRIVATE SECTION.
    DATA mo_aging TYPE REF TO zcl_alloc_aging.

ENDCLASS.


CLASS zcl_alloc_aging_json IMPLEMENTATION.

  METHOD constructor.
    mo_aging = NEW zcl_alloc_aging( ).
  ENDMETHOD.

  METHOD build.
    DATA lv_item  TYPE string.
    DATA lv_first TYPE abap_bool.

    rv_json = '['.
    lv_first = abap_true.

    LOOP AT it_items INTO DATA(ls_item).
      IF lv_first = abap_false.
        rv_json = rv_json && ','.
      ENDIF.
      lv_first = abap_false.

      CLEAR lv_item.
      lv_item = '{'.
      lv_item = lv_item && |"id":"{ ls_item-id }",|.
      lv_item = lv_item && |"days_overdue":{ ls_item-days_overdue },|.
      lv_item = lv_item && |"bucket":{ mo_aging->bucket( ls_item-days_overdue ) }|.
      lv_item = lv_item && '}'.

      rv_json = rv_json && lv_item.
    ENDLOOP.

    rv_json = rv_json && ']'.
  ENDMETHOD.

ENDCLASS.
