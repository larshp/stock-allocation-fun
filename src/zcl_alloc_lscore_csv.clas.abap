CLASS zcl_alloc_lscore_csv DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_lines_tt TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_item,
             lgort    TYPE lgort_d,
             fill_pct TYPE i,
             distance TYPE i,
             picks    TYPE i,
           END OF ty_item.
    TYPES ty_item_tt TYPE STANDARD TABLE OF ty_item WITH DEFAULT KEY.

    METHODS constructor.

    METHODS build
      IMPORTING
        it_items        TYPE ty_item_tt
      RETURNING
        VALUE(rt_lines) TYPE ty_lines_tt.

  PRIVATE SECTION.
    DATA mo_csv   TYPE REF TO zcl_alloc_csv.
    DATA mo_score TYPE REF TO zcl_alloc_location_score.

ENDCLASS.


CLASS zcl_alloc_lscore_csv IMPLEMENTATION.

  METHOD constructor.
    mo_csv = NEW zcl_alloc_csv( ).
    mo_score = NEW zcl_alloc_location_score( ).
  ENDMETHOD.

  METHOD build.
    DATA lt_fields TYPE zcl_alloc_csv=>ty_field_tt.
    DATA lv_line   TYPE string.
    DATA lv_score  TYPE i.
    DATA ls_input  TYPE zcl_alloc_location_score=>ty_input.

    APPEND 'LGORT' TO lt_fields.
    APPEND 'FILL_PCT' TO lt_fields.
    APPEND 'DISTANCE' TO lt_fields.
    APPEND 'PICKS' TO lt_fields.
    APPEND 'SCORE' TO lt_fields.
    lv_line = mo_csv->build_line( lt_fields ).
    APPEND lv_line TO rt_lines.

    LOOP AT it_items INTO DATA(ls_item).
      CLEAR ls_input.
      ls_input-fill_pct = ls_item-fill_pct.
      ls_input-distance = ls_item-distance.
      ls_input-picks = ls_item-picks.

      lv_score = mo_score->score( ls_input ).

      CLEAR lt_fields.
      APPEND |{ ls_item-lgort }| TO lt_fields.
      APPEND |{ ls_item-fill_pct }| TO lt_fields.
      APPEND |{ ls_item-distance }| TO lt_fields.
      APPEND |{ ls_item-picks }| TO lt_fields.
      APPEND |{ lv_score }| TO lt_fields.

      lv_line = mo_csv->build_line( lt_fields ).
      APPEND lv_line TO rt_lines.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
