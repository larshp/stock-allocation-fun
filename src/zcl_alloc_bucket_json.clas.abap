CLASS zcl_alloc_bucket_json DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_item,
             value TYPE menge_d,
           END OF ty_item.
    TYPES ty_item_tt TYPE STANDARD TABLE OF ty_item WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_input,
             items      TYPE ty_item_tt,
             boundaries TYPE zcl_alloc_bucket=>ty_qty_tt,
           END OF ty_input.

    METHODS constructor.

    METHODS build
      IMPORTING
        is_input       TYPE ty_input
      RETURNING
        VALUE(rv_json) TYPE string.

  PRIVATE SECTION.
    DATA mo_bucket TYPE REF TO zcl_alloc_bucket.

ENDCLASS.


CLASS zcl_alloc_bucket_json IMPLEMENTATION.

  METHOD constructor.
    mo_bucket = NEW zcl_alloc_bucket( ).
  ENDMETHOD.

  METHOD build.
    DATA lv_item  TYPE string.
    DATA lv_first TYPE abap_bool.
    DATA ls_input TYPE zcl_alloc_bucket=>ty_input.

    rv_json = '['.
    lv_first = abap_true.

    LOOP AT is_input-items INTO DATA(ls_item).
      IF lv_first = abap_false.
        rv_json = rv_json && ','.
      ENDIF.
      lv_first = abap_false.

      CLEAR ls_input.
      ls_input-value = ls_item-value.
      ls_input-boundaries = is_input-boundaries.

      CLEAR lv_item.
      lv_item = '{'.
      lv_item = lv_item && |"value":{ ls_item-value },|.
      lv_item = lv_item && |"bucket":{ mo_bucket->bucket( ls_input ) }|.
      lv_item = lv_item && '}'.

      rv_json = rv_json && lv_item.
    ENDLOOP.

    rv_json = rv_json && ']'.
  ENDMETHOD.

ENDCLASS.
