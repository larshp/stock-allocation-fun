CLASS zcl_alloc_return_dash DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             label TYPE string,
             value TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    TYPES ty_text_tt TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

    METHODS build
      IMPORTING
        it_lines       TYPE ty_line_tt
      RETURNING
        VALUE(rt_text) TYPE ty_text_tt.

    METHODS line_count
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rv_count) TYPE i.

    METHODS join
      IMPORTING
        it_lines       TYPE ty_line_tt
      RETURNING
        VALUE(rv_text) TYPE string.

ENDCLASS.


CLASS zcl_alloc_return_dash IMPLEMENTATION.

  METHOD build.
    DATA lv_value TYPE i.

    " Each named measure becomes one "label: value" line; a blank label is
    " dropped.
    LOOP AT it_lines INTO DATA(ls_line).
      IF ls_line-label IS INITIAL.
        CONTINUE.
      ENDIF.

      lv_value = ls_line-value.
      APPEND |{ ls_line-label }: { lv_value }| TO rt_text.
    ENDLOOP.
  ENDMETHOD.

  METHOD line_count.
    LOOP AT it_lines INTO DATA(ls_line).
      IF ls_line-label IS NOT INITIAL.
        rv_count = rv_count + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD join.
    DATA lt_text  TYPE ty_text_tt.
    DATA lv_first TYPE abap_bool.

    " The dashboard text joins the lines with a semicolon separator.
    lt_text = build( it_lines ).

    LOOP AT lt_text INTO DATA(lv_line).
      IF lv_first = abap_false.
        lv_first = abap_true.
      ELSE.
        rv_text = |{ rv_text }; |.
      ENDIF.

      rv_text = |{ rv_text }{ lv_line }|.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
