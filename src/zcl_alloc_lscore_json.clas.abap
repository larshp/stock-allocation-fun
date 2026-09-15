CLASS zcl_alloc_lscore_json DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
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
        it_items       TYPE ty_item_tt
      RETURNING
        VALUE(rv_json) TYPE string.

  PRIVATE SECTION.
    DATA mo_score TYPE REF TO zcl_alloc_location_score.

ENDCLASS.


CLASS zcl_alloc_lscore_json IMPLEMENTATION.

  METHOD constructor.
    mo_score = NEW zcl_alloc_location_score( ).
  ENDMETHOD.

  METHOD build.
    DATA lv_item  TYPE string.
    DATA lv_first TYPE abap_bool.
    DATA lv_score TYPE i.
    DATA ls_input TYPE zcl_alloc_location_score=>ty_input.

    rv_json = '['.
    lv_first = abap_true.

    LOOP AT it_items INTO DATA(ls_item).
      IF lv_first = abap_false.
        rv_json = rv_json && ','.
      ENDIF.
      lv_first = abap_false.

      CLEAR ls_input.
      ls_input-fill_pct = ls_item-fill_pct.
      ls_input-distance = ls_item-distance.
      ls_input-picks = ls_item-picks.

      lv_score = mo_score->score( ls_input ).

      CLEAR lv_item.
      lv_item = '{'.
      lv_item = lv_item && |"lgort":"{ ls_item-lgort }",|.
      lv_item = lv_item && |"fill_pct":{ ls_item-fill_pct },|.
      lv_item = lv_item && |"distance":{ ls_item-distance },|.
      lv_item = lv_item && |"picks":{ ls_item-picks },|.
      lv_item = lv_item && |"score":{ lv_score }|.
      lv_item = lv_item && '}'.

      rv_json = rv_json && lv_item.
    ENDLOOP.

    rv_json = rv_json && ']'.
  ENDMETHOD.

ENDCLASS.
