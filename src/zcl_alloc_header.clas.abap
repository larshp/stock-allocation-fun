CLASS zcl_alloc_header DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_text_tt TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_input,
             title    TYPE string,
             subtitle TYPE string,
             user_id  TYPE string,
             run_date TYPE d,
           END OF ty_input.

    TYPES: BEGIN OF ty_result,
             lines    TYPE ty_text_tt,
             rule     TYPE string,
             run_date TYPE d,
           END OF ty_result.

    METHODS build
      IMPORTING
        is_input         TYPE ty_input
        iv_width         TYPE i
      RETURNING
        VALUE(rs_result) TYPE ty_result.

  PRIVATE SECTION.
    CONSTANTS c_max_width TYPE i VALUE 200.
    CONSTANTS c_user_tag  TYPE string VALUE 'User:'.

ENDCLASS.


CLASS zcl_alloc_header IMPLEMENTATION.

  METHOD build.
    DATA lv_width TYPE i.
    DATA lv_i     TYPE i.
    DATA lv_user  TYPE string.

    rs_result-run_date = is_input-run_date.

    IF is_input-title IS NOT INITIAL.
      APPEND is_input-title TO rs_result-lines.
    ENDIF.

    IF is_input-subtitle IS NOT INITIAL.
      APPEND is_input-subtitle TO rs_result-lines.
    ENDIF.

    IF is_input-user_id IS NOT INITIAL.
      " The blank is a backtick literal because a trailing blank in a normal
      " literal is not preserved (ANOMALIES.md A18).
      lv_user = c_user_tag.
      lv_user = lv_user && ` `.
      lv_user = lv_user && is_input-user_id.
      APPEND lv_user TO rs_result-lines.
    ENDIF.

    lv_width = iv_width.
    IF lv_width < 0.
      lv_width = 0.
    ENDIF.
    IF lv_width > c_max_width.
      lv_width = c_max_width.
    ENDIF.

    WHILE lv_i < lv_width.
      lv_i = lv_i + 1.
      rs_result-rule = rs_result-rule && '-'.
    ENDWHILE.
  ENDMETHOD.

ENDCLASS.
