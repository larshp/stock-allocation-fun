CLASS zcl_alloc_app_log_read DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_lines_tt TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_input,
             entries TYPE zcl_alloc_app_log=>ty_entry_tt,
             level   TYPE c LENGTH 1,
           END OF ty_input.

    METHODS messages
      IMPORTING
        is_input        TYPE ty_input
      RETURNING
        VALUE(rt_lines) TYPE ty_lines_tt.

    METHODS has_errors
      IMPORTING
        it_entries       TYPE zcl_alloc_app_log=>ty_entry_tt
      RETURNING
        VALUE(rv_errors) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_app_log_read IMPLEMENTATION.

  METHOD messages.
    DATA lv_message TYPE string.

    LOOP AT is_input-entries INTO DATA(ls_entry).
      IF ls_entry-level <> is_input-level.
        CONTINUE.
      ENDIF.

      lv_message = ls_entry-message.
      APPEND lv_message TO rt_lines.
    ENDLOOP.
  ENDMETHOD.

  METHOD has_errors.
    LOOP AT it_entries INTO DATA(ls_entry).
      IF ls_entry-level = 'E'.
        rv_errors = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.

    rv_errors = abap_false.
  ENDMETHOD.

ENDCLASS.
