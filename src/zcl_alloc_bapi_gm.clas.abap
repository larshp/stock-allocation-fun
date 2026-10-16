CLASS zcl_alloc_bapi_gm DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_string_tt TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_input,
             matnr     TYPE matnr,
             werks     TYPE werks_d,
             lgort     TYPE lgort_d,
             quantity  TYPE menge_d,
             move_type TYPE c LENGTH 3,
           END OF ty_input.

    TYPES: BEGIN OF ty_result,
             executed   TYPE abap_bool,
             doc_number TYPE c LENGTH 10,
             messages   TYPE ty_string_tt,
           END OF ty_result.

    METHODS post
      IMPORTING
        is_input         TYPE ty_input
      RETURNING
        VALUE(rs_result) TYPE ty_result.

ENDCLASS.


CLASS zcl_alloc_bapi_gm IMPLEMENTATION.

  METHOD post.
    IF is_input-matnr IS INITIAL.
      APPEND 'Material is missing' TO rs_result-messages.
      RETURN.
    ENDIF.

    IF is_input-werks IS INITIAL.
      APPEND 'Plant is missing' TO rs_result-messages.
      RETURN.
    ENDIF.

    IF is_input-quantity <= 0.
      APPEND 'Quantity must be positive' TO rs_result-messages.
      RETURN.
    ENDIF.

    rs_result-executed = abap_true.
    rs_result-doc_number = '4900000001'.
  ENDMETHOD.

ENDCLASS.
