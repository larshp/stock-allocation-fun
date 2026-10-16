CLASS zcl_alloc_idoc_reader DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_string_tt TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_input,
             segments TYPE ty_string_tt,
           END OF ty_input.

    TYPES: BEGIN OF ty_result,
             valid    TYPE abap_bool,
             matnr    TYPE matnr,
             quantity TYPE menge_d,
             messages TYPE ty_string_tt,
           END OF ty_result.

    METHODS read
      IMPORTING
        is_input         TYPE ty_input
      RETURNING
        VALUE(rs_result) TYPE ty_result.

ENDCLASS.


CLASS zcl_alloc_idoc_reader IMPLEMENTATION.

  METHOD read.
    DATA lv_segment TYPE string.
    DATA lv_value   TYPE string.

    LOOP AT is_input-segments INTO lv_segment.
      IF lv_segment = 'EDI_DC40'.
        rs_result-valid = abap_true.
        CONTINUE.
      ENDIF.

      IF lv_segment(8) = 'E1EDP19:'.
        lv_value = lv_segment.
        rs_result-matnr = substring( val = lv_value off = 8 ).
        CONTINUE.
      ENDIF.

      IF lv_segment(8) = 'E1EDP26:'.
        lv_value = lv_segment.
        rs_result-quantity = substring( val = lv_value off = 8 ).
      ENDIF.
    ENDLOOP.

    IF rs_result-valid = abap_false.
      APPEND 'Header segment missing' TO rs_result-messages.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
