CLASS zcl_alloc_exception_map DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_input,
             class TYPE c LENGTH 30,
             code  TYPE c LENGTH 20,
           END OF ty_input.

    TYPES: BEGIN OF ty_result,
             category    TYPE c LENGTH 20,
             retryable   TYPE abap_bool,
             http_status TYPE i,
           END OF ty_result.

    METHODS map
      IMPORTING
        is_input         TYPE ty_input
      RETURNING
        VALUE(rs_result) TYPE ty_result.

ENDCLASS.


CLASS zcl_alloc_exception_map IMPLEMENTATION.

  METHOD map.
    IF is_input-class(6) = 'CX_SY_'.
      rs_result-category = 'SYSTEM'.
      rs_result-retryable = abap_true.
      rs_result-http_status = 500.
      RETURN.
    ENDIF.

    IF is_input-class(8) = 'CX_ABAP_'.
      rs_result-category = 'ABAP'.
      rs_result-retryable = abap_false.
      rs_result-http_status = 500.
      RETURN.
    ENDIF.

    rs_result-category = 'UNKNOWN'.
    rs_result-retryable = abap_false.
    rs_result-http_status = 400.
  ENDMETHOD.

ENDCLASS.
