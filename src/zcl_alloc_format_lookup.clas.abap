CLASS zcl_alloc_format_lookup DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_input,
             entries TYPE zcl_alloc_format_registry=>ty_entry_tt,
             name    TYPE zcl_alloc_format_registry=>ty_name,
           END OF ty_input.

    METHODS lookup
      IMPORTING
        is_input         TYPE ty_input
      RETURNING
        VALUE(rv_format) TYPE zcl_alloc_format_registry=>ty_format.

ENDCLASS.


CLASS zcl_alloc_format_lookup IMPLEMENTATION.

  METHOD lookup.
    READ TABLE is_input-entries INTO DATA(ls_entry)
      WITH KEY name = is_input-name.
    IF sy-subrc = 0.
      rv_format = ls_entry-format.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
