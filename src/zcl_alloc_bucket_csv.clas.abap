CLASS zcl_alloc_bucket_csv DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_lines_tt TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

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
        is_input        TYPE ty_input
      RETURNING
        VALUE(rt_lines) TYPE ty_lines_tt.

  PRIVATE SECTION.
    DATA mo_csv    TYPE REF TO zcl_alloc_csv.
    DATA mo_bucket TYPE REF TO zcl_alloc_bucket.

ENDCLASS.


CLASS zcl_alloc_bucket_csv IMPLEMENTATION.

  METHOD constructor.
    mo_csv = NEW zcl_alloc_csv( ).
    mo_bucket = NEW zcl_alloc_bucket( ).
  ENDMETHOD.

  METHOD build.
    DATA lt_fields TYPE zcl_alloc_csv=>ty_field_tt.
    DATA lv_line   TYPE string.
    DATA ls_input  TYPE zcl_alloc_bucket=>ty_input.

    APPEND 'VALUE' TO lt_fields.
    APPEND 'BUCKET' TO lt_fields.
    lv_line = mo_csv->build_line( lt_fields ).
    APPEND lv_line TO rt_lines.

    LOOP AT is_input-items INTO DATA(ls_item).
      CLEAR ls_input.
      ls_input-value = ls_item-value.
      ls_input-boundaries = is_input-boundaries.

      CLEAR lt_fields.
      APPEND |{ ls_item-value }| TO lt_fields.
      APPEND |{ mo_bucket->bucket( ls_input ) }| TO lt_fields.

      lv_line = mo_csv->build_line( lt_fields ).
      APPEND lv_line TO rt_lines.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
