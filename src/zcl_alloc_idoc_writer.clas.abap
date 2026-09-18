CLASS zcl_alloc_idoc_writer DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_string_tt TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_input,
             idoc_type    TYPE c LENGTH 10,
             message_type TYPE c LENGTH 30,
             matnr        TYPE matnr,
             quantity     TYPE menge_d,
           END OF ty_input.

    TYPES: BEGIN OF ty_result,
             idoc_number TYPE c LENGTH 16,
             segments    TYPE ty_string_tt,
           END OF ty_result.

    METHODS create
      IMPORTING
        is_input         TYPE ty_input
      RETURNING
        VALUE(rs_result) TYPE ty_result.

ENDCLASS.


CLASS zcl_alloc_idoc_writer IMPLEMENTATION.

  METHOD create.
    IF is_input-matnr IS INITIAL OR is_input-quantity <= 0.
      APPEND 'IDoc not created' TO rs_result-segments.
      RETURN.
    ENDIF.

    APPEND 'EDI_DC40' TO rs_result-segments.
    APPEND |E1EDP19:{ is_input-matnr }| TO rs_result-segments.
    APPEND |E1EDP26:{ is_input-quantity }| TO rs_result-segments.

    rs_result-idoc_number = '0000000000000001'.
  ENDMETHOD.

ENDCLASS.
