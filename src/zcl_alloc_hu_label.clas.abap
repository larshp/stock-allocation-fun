CLASS zcl_alloc_hu_label DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_field,
             name  TYPE string,
             value TYPE string,
           END OF ty_field.
    TYPES ty_field_tt TYPE STANDARD TABLE OF ty_field WITH DEFAULT KEY.
    TYPES ty_lines_tt TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

    METHODS build
      IMPORTING
        iv_title        TYPE string
        it_fields       TYPE ty_field_tt
      RETURNING
        VALUE(rt_lines) TYPE ty_lines_tt.

ENDCLASS.


CLASS zcl_alloc_hu_label IMPLEMENTATION.

  METHOD build.
    DATA lv_line TYPE string.

    IF iv_title IS NOT INITIAL.
      APPEND iv_title TO rt_lines.
    ENDIF.

    " Every value is already text, so the label never has to convert a number,
    " which keeps the output independent of the runtime's number formatting.
    LOOP AT it_fields INTO DATA(ls_field).
      IF ls_field-name IS INITIAL.
        CONTINUE.
      ENDIF.

      lv_line = ls_field-name.
      " A backtick literal is a string, so the blank after the colon survives;
      " a single-quoted literal is a character field and trailing blanks are cut.
      lv_line = lv_line && `: `.
      lv_line = lv_line && ls_field-value.
      APPEND lv_line TO rt_lines.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
