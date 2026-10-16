CLASS zcl_alloc_format_registry DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_name   TYPE c LENGTH 20.
    TYPES ty_format TYPE c LENGTH 10.

    TYPES: BEGIN OF ty_entry,
             name   TYPE ty_name,
             format TYPE ty_format,
           END OF ty_entry.
    TYPES ty_entry_tt TYPE STANDARD TABLE OF ty_entry WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_add_input,
             entries TYPE ty_entry_tt,
             entry   TYPE ty_entry,
           END OF ty_add_input.

    METHODS add
      IMPORTING
        is_add            TYPE ty_add_input
      RETURNING
        VALUE(rt_entries) TYPE ty_entry_tt.

ENDCLASS.


CLASS zcl_alloc_format_registry IMPLEMENTATION.

  METHOD add.
    rt_entries = is_add-entries.

    READ TABLE rt_entries ASSIGNING FIELD-SYMBOL(<ls_entry>)
      WITH KEY name = is_add-entry-name.
    IF sy-subrc = 0.
      <ls_entry>-format = is_add-entry-format.
    ELSE.
      APPEND is_add-entry TO rt_entries.
    ENDIF.

    SORT rt_entries BY name ASCENDING.
  ENDMETHOD.

ENDCLASS.
