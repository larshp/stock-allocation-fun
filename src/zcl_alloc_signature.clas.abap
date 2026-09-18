CLASS zcl_alloc_signature DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_text_tt TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_input,
             user_id   TYPE string,
             system_id TYPE string,
             client_id TYPE string,
             run_date  TYPE d,
             run_time  TYPE t,
           END OF ty_input.

    TYPES: BEGIN OF ty_result,
             lines    TYPE ty_text_tt,
             run_date TYPE d,
             run_time TYPE t,
           END OF ty_result.

    METHODS build
      IMPORTING
        is_input         TYPE ty_input
      RETURNING
        VALUE(rs_result) TYPE ty_result.

  PRIVATE SECTION.
    CONSTANTS c_user_tag   TYPE string VALUE 'User:'.
    CONSTANTS c_system_tag TYPE string VALUE 'System:'.

ENDCLASS.


CLASS zcl_alloc_signature IMPLEMENTATION.

  METHOD build.
    DATA lv_line TYPE string.

    rs_result-run_date = is_input-run_date.
    rs_result-run_time = is_input-run_time.

    IF is_input-user_id IS NOT INITIAL.
      " The blank is a backtick literal because a trailing blank in a normal
      " literal is not preserved (ANOMALIES.md A18).
      lv_line = c_user_tag.
      lv_line = lv_line && ` `.
      lv_line = lv_line && is_input-user_id.
      APPEND lv_line TO rs_result-lines.
    ENDIF.

    IF is_input-system_id IS NOT INITIAL.
      lv_line = c_system_tag.
      lv_line = lv_line && ` `.
      lv_line = lv_line && is_input-system_id.

      IF is_input-client_id IS NOT INITIAL.
        lv_line = lv_line && '/'.
        lv_line = lv_line && is_input-client_id.
      ENDIF.

      APPEND lv_line TO rs_result-lines.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
