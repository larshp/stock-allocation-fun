CLASS zcl_alloc_enqueue DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_input,
             object TYPE c LENGTH 30,
             key    TYPE c LENGTH 20,
           END OF ty_input.

    TYPES: BEGIN OF ty_result,
             accepted TYPE abap_bool,
             message  TYPE c LENGTH 60,
           END OF ty_result.

    METHODS enqueue
      IMPORTING
        is_input         TYPE ty_input
      RETURNING
        VALUE(rs_result) TYPE ty_result.

ENDCLASS.


CLASS zcl_alloc_enqueue IMPLEMENTATION.

  METHOD enqueue.
    IF is_input-object IS INITIAL.
      rs_result-accepted = abap_false.
      rs_result-message = 'Object is empty'.
      RETURN.
    ENDIF.

    IF is_input-key IS INITIAL.
      rs_result-accepted = abap_false.
      rs_result-message = 'Key is empty'.
      RETURN.
    ENDIF.

    rs_result-accepted = abap_true.
    rs_result-message = 'Locked'.
  ENDMETHOD.

ENDCLASS.
