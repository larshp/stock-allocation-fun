CLASS zcl_alloc_change_read DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_input,
             changes TYPE zcl_alloc_change_doc=>ty_change_tt,
             object  TYPE c LENGTH 30,
             key     TYPE c LENGTH 20,
           END OF ty_input.

    TYPES: BEGIN OF ty_field_input,
             changes TYPE zcl_alloc_change_doc=>ty_change_tt,
             field   TYPE c LENGTH 20,
           END OF ty_field_input.

    METHODS of_object
      IMPORTING
        is_input          TYPE ty_input
      RETURNING
        VALUE(rt_changes) TYPE zcl_alloc_change_doc=>ty_change_tt.

    METHODS field_count
      IMPORTING
        is_input        TYPE ty_field_input
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_change_read IMPLEMENTATION.

  METHOD of_object.
    LOOP AT is_input-changes INTO DATA(ls_change).
      IF ls_change-object <> is_input-object
          OR ls_change-key <> is_input-key.
        CONTINUE.
      ENDIF.

      APPEND ls_change TO rt_changes.
    ENDLOOP.
  ENDMETHOD.

  METHOD field_count.
    DATA lv_count TYPE i.

    LOOP AT is_input-changes INTO DATA(ls_change).
      IF ls_change-field = is_input-field.
        lv_count = lv_count + 1.
      ENDIF.
    ENDLOOP.

    rv_count = lv_count.
  ENDMETHOD.

ENDCLASS.
