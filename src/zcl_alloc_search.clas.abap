CLASS zcl_alloc_search DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_item,
             key  TYPE c LENGTH 20,
             text TYPE c LENGTH 40,
           END OF ty_item.
    TYPES ty_item_tt TYPE STANDARD TABLE OF ty_item WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_input,
             items TYPE ty_item_tt,
             term  TYPE c LENGTH 20,
           END OF ty_input.

    METHODS filter
      IMPORTING
        is_input        TYPE ty_input
      RETURNING
        VALUE(rt_lines) TYPE ty_item_tt.

ENDCLASS.


CLASS zcl_alloc_search IMPLEMENTATION.

  METHOD filter.
    DATA lv_text    TYPE string.
    DATA lv_term    TYPE string.
    DATA lv_up_text TYPE string.
    DATA lv_up_term TYPE string.

    lv_term = is_input-term.
    lv_up_term = to_upper( lv_term ).

    LOOP AT is_input-items INTO DATA(ls_item).
      lv_text = ls_item-text.
      lv_up_text = to_upper( lv_text ).

      IF find( val = lv_up_text
               sub = lv_up_term ) <> -1.
        APPEND ls_item TO rt_lines.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
