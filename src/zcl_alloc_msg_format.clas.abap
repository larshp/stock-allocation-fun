CLASS zcl_alloc_msg_format DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_input,
             msgty TYPE c LENGTH 1,
             msgid TYPE c LENGTH 20,
             msgno TYPE c LENGTH 3,
             text  TYPE c LENGTH 80,
           END OF ty_input.

    METHODS format
      IMPORTING
        is_input       TYPE ty_input
      RETURNING
        VALUE(rv_text) TYPE string.

    METHODS short
      IMPORTING
        is_input        TYPE ty_input
      RETURNING
        VALUE(rv_short) TYPE string.

ENDCLASS.


CLASS zcl_alloc_msg_format IMPLEMENTATION.

  METHOD format.
    rv_text = |{ is_input-msgty } { is_input-msgid } { is_input-msgno } { is_input-text }|.
  ENDMETHOD.

  METHOD short.
    rv_short = |{ is_input-msgty }{ is_input-msgno }|.
  ENDMETHOD.

ENDCLASS.
