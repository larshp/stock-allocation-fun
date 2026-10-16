CLASS zcl_alloc_rfc DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_input,
             destination TYPE c LENGTH 20,
             function    TYPE c LENGTH 30,
           END OF ty_input.

    TYPES: BEGIN OF ty_result,
             connected TYPE abap_bool,
             message   TYPE c LENGTH 80,
           END OF ty_result.

    METHODS ping
      IMPORTING
        is_input         TYPE ty_input
      RETURNING
        VALUE(rs_result) TYPE ty_result.

    METHODS describe
      IMPORTING
        is_input       TYPE ty_input
      RETURNING
        VALUE(rv_text) TYPE string.

ENDCLASS.


CLASS zcl_alloc_rfc IMPLEMENTATION.

  METHOD ping.
    IF is_input-destination IS INITIAL.
      rs_result-connected = abap_false.
      rs_result-message = 'Destination is empty'.
      RETURN.
    ENDIF.

    rs_result-connected = abap_true.
    rs_result-message = 'Connected'.
  ENDMETHOD.

  METHOD describe.
    rv_text = |{ is_input-destination }:{ is_input-function }|.
  ENDMETHOD.

ENDCLASS.
