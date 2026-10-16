CLASS zcl_alloc_aging_csv DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_lines_tt TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_item,
             id           TYPE c LENGTH 20,
             days_overdue TYPE i,
           END OF ty_item.
    TYPES ty_item_tt TYPE STANDARD TABLE OF ty_item WITH DEFAULT KEY.

    METHODS constructor.

    METHODS build
      IMPORTING
        it_items        TYPE ty_item_tt
      RETURNING
        VALUE(rt_lines) TYPE ty_lines_tt.

  PRIVATE SECTION.
    DATA mo_csv    TYPE REF TO zcl_alloc_csv.
    DATA mo_aging  TYPE REF TO zcl_alloc_aging.

ENDCLASS.


CLASS zcl_alloc_aging_csv IMPLEMENTATION.

  METHOD constructor.
    mo_csv = NEW zcl_alloc_csv( ).
    mo_aging = NEW zcl_alloc_aging( ).
  ENDMETHOD.

  METHOD build.
    DATA lt_fields TYPE zcl_alloc_csv=>ty_field_tt.
    DATA lv_line   TYPE string.

    APPEND 'ID' TO lt_fields.
    APPEND 'DAYS_OVERDUE' TO lt_fields.
    APPEND 'BUCKET' TO lt_fields.
    lv_line = mo_csv->build_line( lt_fields ).
    APPEND lv_line TO rt_lines.

    LOOP AT it_items INTO DATA(ls_item).
      CLEAR lt_fields.
      APPEND |{ ls_item-id }| TO lt_fields.
      APPEND |{ ls_item-days_overdue }| TO lt_fields.
      APPEND |{ mo_aging->bucket( ls_item-days_overdue ) }| TO lt_fields.

      lv_line = mo_csv->build_line( lt_fields ).
      APPEND lv_line TO rt_lines.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
