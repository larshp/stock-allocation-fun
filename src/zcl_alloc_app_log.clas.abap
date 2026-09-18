CLASS zcl_alloc_app_log DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_entry,
             object    TYPE c LENGTH 20,
             subobject TYPE c LENGTH 20,
             level     TYPE c LENGTH 1,
             message   TYPE c LENGTH 80,
           END OF ty_entry.
    TYPES ty_entry_tt TYPE STANDARD TABLE OF ty_entry WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_input,
             entries TYPE ty_entry_tt,
             entry   TYPE ty_entry,
           END OF ty_input.

    TYPES: BEGIN OF ty_level_input,
             entries TYPE ty_entry_tt,
             level   TYPE c LENGTH 1,
           END OF ty_level_input.

    METHODS write
      IMPORTING
        is_input          TYPE ty_input
      RETURNING
        VALUE(rt_entries) TYPE ty_entry_tt.

    METHODS count_of_level
      IMPORTING
        is_input        TYPE ty_level_input
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_app_log IMPLEMENTATION.

  METHOD write.
    rt_entries = is_input-entries.

    APPEND is_input-entry TO rt_entries.
  ENDMETHOD.

  METHOD count_of_level.
    DATA lv_count TYPE i.

    LOOP AT is_input-entries INTO DATA(ls_entry).
      IF ls_entry-level = is_input-level.
        lv_count = lv_count + 1.
      ENDIF.
    ENDLOOP.

    rv_count = lv_count.
  ENDMETHOD.

ENDCLASS.
