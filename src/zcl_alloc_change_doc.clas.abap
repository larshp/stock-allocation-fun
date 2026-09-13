CLASS zcl_alloc_change_doc DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_change,
             object    TYPE c LENGTH 30,
             key       TYPE c LENGTH 20,
             field     TYPE c LENGTH 20,
             old_value TYPE c LENGTH 40,
             new_value TYPE c LENGTH 40,
           END OF ty_change.
    TYPES ty_change_tt TYPE STANDARD TABLE OF ty_change WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_input,
             changes TYPE ty_change_tt,
             change  TYPE ty_change,
           END OF ty_input.

    METHODS add
      IMPORTING
        is_input          TYPE ty_input
      RETURNING
        VALUE(rt_changes) TYPE ty_change_tt.

ENDCLASS.


CLASS zcl_alloc_change_doc IMPLEMENTATION.

  METHOD add.
    rt_changes = is_input-changes.

    " only a real change is worth documenting
    IF is_input-change-old_value = is_input-change-new_value.
      RETURN.
    ENDIF.

    APPEND is_input-change TO rt_changes.
  ENDMETHOD.

ENDCLASS.
