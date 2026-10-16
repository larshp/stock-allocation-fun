CLASS zcl_alloc_prio_csv DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_lines_tt TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_item,
             requirement_id TYPE zcl_stock_allocator=>ty_result-requirement_id,
             factors        TYPE zcl_alloc_priority=>ty_factors,
           END OF ty_item.
    TYPES ty_item_tt TYPE STANDARD TABLE OF ty_item WITH DEFAULT KEY.

    METHODS constructor.

    METHODS build
      IMPORTING
        it_items        TYPE ty_item_tt
      RETURNING
        VALUE(rt_lines) TYPE ty_lines_tt.

  PRIVATE SECTION.
    DATA mo_csv  TYPE REF TO zcl_alloc_csv.
    DATA mo_prio TYPE REF TO zcl_alloc_priority.

ENDCLASS.


CLASS zcl_alloc_prio_csv IMPLEMENTATION.

  METHOD constructor.
    mo_csv = NEW zcl_alloc_csv( ).
    mo_prio = NEW zcl_alloc_priority( ).
  ENDMETHOD.

  METHOD build.
    DATA lt_fields TYPE zcl_alloc_csv=>ty_field_tt.
    DATA lv_line   TYPE string.
    DATA lv_score  TYPE i.

    APPEND 'REQUIREMENT_ID' TO lt_fields.
    APPEND 'DELIVERY_PRIORITY' TO lt_fields.
    APPEND 'DAYS_UNTIL_DUE' TO lt_fields.
    APPEND 'CUSTOMER_WEIGHT' TO lt_fields.
    APPEND 'SCORE' TO lt_fields.
    lv_line = mo_csv->build_line( lt_fields ).
    APPEND lv_line TO rt_lines.

    LOOP AT it_items INTO DATA(ls_item).
      lv_score = mo_prio->score( is_factors = ls_item-factors ).

      CLEAR lt_fields.
      APPEND |{ ls_item-requirement_id }| TO lt_fields.
      APPEND |{ ls_item-factors-delivery_priority }| TO lt_fields.
      APPEND |{ ls_item-factors-days_until_due }| TO lt_fields.
      APPEND |{ ls_item-factors-customer_weight }| TO lt_fields.
      APPEND |{ lv_score }| TO lt_fields.

      lv_line = mo_csv->build_line( lt_fields ).
      APPEND lv_line TO rt_lines.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
