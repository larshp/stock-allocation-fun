CLASS zcl_alloc_bapi_plant DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_input,
             werks TYPE werks_d,
           END OF ty_input.

    TYPES: BEGIN OF ty_result,
             found   TYPE abap_bool,
             werks   TYPE werks_d,
             name    TYPE c LENGTH 40,
             country TYPE c LENGTH 3,
           END OF ty_result.

    METHODS read
      IMPORTING
        is_input         TYPE ty_input
      RETURNING
        VALUE(rs_result) TYPE ty_result.

ENDCLASS.


CLASS zcl_alloc_bapi_plant IMPLEMENTATION.

  METHOD read.
    IF is_input-werks IS INITIAL.
      rs_result-found = abap_false.
      RETURN.
    ENDIF.

    rs_result-found = abap_true.
    rs_result-werks = is_input-werks.
    rs_result-name = 'Allocation plant'.
    rs_result-country = 'DE'.
  ENDMETHOD.

ENDCLASS.
