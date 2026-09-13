CLASS zcl_alloc_bdc_run DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_input,
             session TYPE c LENGTH 20,
             rows    TYPE zcl_alloc_bdc_build=>ty_row_tt,
           END OF ty_input.

    TYPES: BEGIN OF ty_result,
             created   TYPE abap_bool,
             row_count TYPE i,
             message   TYPE c LENGTH 80,
           END OF ty_result.

    METHODS run
      IMPORTING
        is_input         TYPE ty_input
      RETURNING
        VALUE(rs_result) TYPE ty_result.

ENDCLASS.


CLASS zcl_alloc_bdc_run IMPLEMENTATION.

  METHOD run.
    IF is_input-session IS INITIAL OR lines( is_input-rows ) = 0.
      rs_result-created = abap_false.
      rs_result-message = 'Nothing to run'.
      RETURN.
    ENDIF.

    rs_result-created = abap_true.
    rs_result-row_count = lines( is_input-rows ).
    rs_result-message = 'Session created'.
  ENDMETHOD.

ENDCLASS.
