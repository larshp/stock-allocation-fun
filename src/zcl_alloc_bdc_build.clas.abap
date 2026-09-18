CLASS zcl_alloc_bdc_build DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_row,
             program TYPE c LENGTH 20,
             dynpro  TYPE c LENGTH 4,
             field   TYPE c LENGTH 20,
             value   TYPE c LENGTH 40,
           END OF ty_row.
    TYPES ty_row_tt TYPE STANDARD TABLE OF ty_row WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_input,
             rows    TYPE ty_row_tt,
             program TYPE c LENGTH 20,
             dynpro  TYPE c LENGTH 4,
             field   TYPE c LENGTH 20,
             value   TYPE c LENGTH 40,
           END OF ty_input.

    METHODS add
      IMPORTING
        is_input       TYPE ty_input
      RETURNING
        VALUE(rt_rows) TYPE ty_row_tt.

ENDCLASS.


CLASS zcl_alloc_bdc_build IMPLEMENTATION.

  METHOD add.
    rt_rows = is_input-rows.

    IF is_input-field IS INITIAL OR is_input-value IS INITIAL.
      RETURN.
    ENDIF.

    APPEND VALUE #( program = is_input-program
                    dynpro  = is_input-dynpro
                    field   = is_input-field
                    value   = is_input-value ) TO rt_rows.
  ENDMETHOD.

ENDCLASS.
