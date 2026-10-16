CLASS zcl_alloc_error DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_error,
             code TYPE c LENGTH 20,
             text TYPE c LENGTH 80,
           END OF ty_error.
    TYPES ty_error_tt TYPE STANDARD TABLE OF ty_error WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_input,
             errors TYPE ty_error_tt,
             error  TYPE ty_error,
             text   TYPE c LENGTH 80,
           END OF ty_input.

    METHODS raise
      IMPORTING
        is_input         TYPE ty_input
      RETURNING
        VALUE(rt_errors) TYPE ty_error_tt.

    METHODS has_any
      IMPORTING
        it_errors     TYPE ty_error_tt
      RETURNING
        VALUE(rv_any) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_error IMPLEMENTATION.

  METHOD raise.
    rt_errors = is_input-errors.

    IF is_input-text IS INITIAL.
      RETURN.
    ENDIF.

    APPEND is_input-error TO rt_errors.
  ENDMETHOD.

  METHOD has_any.
    IF lines( it_errors ) > 0.
      rv_any = abap_true.
    ELSE.
      rv_any = abap_false.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
