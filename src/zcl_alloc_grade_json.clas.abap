CLASS zcl_alloc_grade_json DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_item,
             coverage_pct TYPE i,
             has_shortage TYPE abap_bool,
           END OF ty_item.
    TYPES ty_item_tt TYPE STANDARD TABLE OF ty_item WITH DEFAULT KEY.

    METHODS constructor.

    METHODS build
      IMPORTING
        it_items       TYPE ty_item_tt
      RETURNING
        VALUE(rv_json) TYPE string.

  PRIVATE SECTION.
    DATA mo_grade TYPE REF TO zcl_alloc_grade.

    METHODS grade_of
      IMPORTING
        is_item         TYPE ty_item
      RETURNING
        VALUE(rv_grade) TYPE zcl_alloc_grade=>ty_grade.

ENDCLASS.


CLASS zcl_alloc_grade_json IMPLEMENTATION.

  METHOD constructor.
    mo_grade = NEW zcl_alloc_grade( ).
  ENDMETHOD.

  METHOD grade_of.
    DATA ls_input TYPE zcl_alloc_grade=>ty_input.

    ls_input-coverage_pct = is_item-coverage_pct.
    ls_input-has_shortage = is_item-has_shortage.

    rv_grade = mo_grade->grade( ls_input ).
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
      lv_item = lv_item && |"coverage_pct":{ ls_item-coverage_pct },|.
      lv_item = lv_item && |"grade":"{ grade_of( ls_item ) }"|.
      lv_item = lv_item && '}'.

      rv_json = rv_json && lv_item.
    ENDLOOP.

    rv_json = rv_json && ']'.
  ENDMETHOD.

ENDCLASS.
