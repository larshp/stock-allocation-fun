CLASS zcl_alloc_grade_csv DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_lines_tt TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_item,
             coverage_pct TYPE i,
             has_shortage TYPE abap_bool,
           END OF ty_item.
    TYPES ty_item_tt TYPE STANDARD TABLE OF ty_item WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_count,
             grade TYPE zcl_alloc_grade=>ty_grade,
             count TYPE i,
           END OF ty_count.
    TYPES ty_count_tt TYPE STANDARD TABLE OF ty_count WITH DEFAULT KEY.

    METHODS constructor.

    METHODS build
      IMPORTING
        it_items        TYPE ty_item_tt
      RETURNING
        VALUE(rt_lines) TYPE ty_lines_tt.

  PRIVATE SECTION.
    DATA mo_csv   TYPE REF TO zcl_alloc_csv.
    DATA mo_grade TYPE REF TO zcl_alloc_grade.

    METHODS counts_of
      IMPORTING
        it_items         TYPE ty_item_tt
      RETURNING
        VALUE(rt_counts) TYPE ty_count_tt.

ENDCLASS.


CLASS zcl_alloc_grade_csv IMPLEMENTATION.

  METHOD constructor.
    mo_csv = NEW zcl_alloc_csv( ).
    mo_grade = NEW zcl_alloc_grade( ).
  ENDMETHOD.

  METHOD counts_of.
    DATA ls_count TYPE ty_count.
    DATA ls_input TYPE zcl_alloc_grade=>ty_input.
    DATA lv_grade TYPE zcl_alloc_grade=>ty_grade.

    APPEND VALUE #( grade = 'A' ) TO rt_counts.
    APPEND VALUE #( grade = 'B' ) TO rt_counts.
    APPEND VALUE #( grade = 'C' ) TO rt_counts.
    APPEND VALUE #( grade = 'D' ) TO rt_counts.
    APPEND VALUE #( grade = 'E' ) TO rt_counts.
    APPEND VALUE #( grade = 'F' ) TO rt_counts.

    LOOP AT it_items INTO DATA(ls_item).
      CLEAR ls_input.
      ls_input-coverage_pct = ls_item-coverage_pct.
      ls_input-has_shortage = ls_item-has_shortage.

      lv_grade = mo_grade->grade( ls_input ).

      READ TABLE rt_counts ASSIGNING FIELD-SYMBOL(<ls_count>)
        WITH KEY grade = lv_grade.
      IF sy-subrc = 0.
        <ls_count>-count = <ls_count>-count + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD build.
    DATA lt_counts TYPE ty_count_tt.
    DATA lt_fields TYPE zcl_alloc_csv=>ty_field_tt.
    DATA lv_line   TYPE string.

    lt_counts = counts_of( it_items ).

    APPEND 'GRADE' TO lt_fields.
    APPEND 'COUNT' TO lt_fields.
    lv_line = mo_csv->build_line( lt_fields ).
    APPEND lv_line TO rt_lines.

    LOOP AT lt_counts INTO DATA(ls_count).
      CLEAR lt_fields.
      APPEND |{ ls_count-grade }| TO lt_fields.
      APPEND |{ ls_count-count }| TO lt_fields.

      lv_line = mo_csv->build_line( lt_fields ).
      APPEND lv_line TO rt_lines.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
