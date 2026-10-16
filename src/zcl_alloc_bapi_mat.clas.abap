CLASS zcl_alloc_bapi_mat DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_input,
             matnr TYPE matnr,
           END OF ty_input.

    TYPES: BEGIN OF ty_result,
             found       TYPE abap_bool,
             matnr       TYPE matnr,
             description TYPE c LENGTH 40,
             base_unit   TYPE c LENGTH 3,
           END OF ty_result.

    METHODS read
      IMPORTING
        is_input         TYPE ty_input
      RETURNING
        VALUE(rs_result) TYPE ty_result.

ENDCLASS.


CLASS zcl_alloc_bapi_mat IMPLEMENTATION.

  METHOD read.
    IF is_input-matnr IS INITIAL.
      rs_result-found = abap_false.
      RETURN.
    ENDIF.

    rs_result-found = abap_true.
    rs_result-matnr = is_input-matnr.
    rs_result-description = 'Allocation material'.
    rs_result-base_unit = 'ST'.
  ENDMETHOD.

ENDCLASS.
