CLASS zcl_alloc_return_receipt DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_authorised,
             material TYPE matnr,
             quantity TYPE menge_d,
           END OF ty_authorised.
    TYPES ty_authorised_tt TYPE STANDARD TABLE OF ty_authorised WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_received,
             material TYPE matnr,
             quantity TYPE menge_d,
           END OF ty_received.
    TYPES ty_received_tt TYPE STANDARD TABLE OF ty_received WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_line,
             material   TYPE matnr,
             authorised TYPE menge_d,
             received   TYPE menge_d,
             difference TYPE menge_d,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    METHODS build
      IMPORTING
        it_authorised   TYPE ty_authorised_tt
        it_received     TYPE ty_received_tt
      RETURNING
        VALUE(rt_lines) TYPE ty_line_tt.

    METHODS total
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rv_total) TYPE menge_d.

    METHODS short_lines
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_return_receipt IMPLEMENTATION.

  METHOD build.
    DATA lo_received TYPE REF TO zcl_alloc_key_map.
    DATA lv_key      TYPE string.
    DATA ls_line     TYPE ty_line.

    " The received lines are indexed once by material, so a receipt of many lines
    " does not rescan the received list per authorised line.
    lo_received = NEW zcl_alloc_key_map( ).

    LOOP AT it_received INTO DATA(ls_received).
      lv_key = ls_received-material.
      lo_received->add( iv_key   = lv_key
                        iv_delta = ls_received-quantity ).
    ENDLOOP.

    LOOP AT it_authorised INTO DATA(ls_authorised).
      CLEAR ls_line.
      ls_line-material = ls_authorised-material.
      ls_line-authorised = ls_authorised-quantity.

      lv_key = ls_authorised-material.
      ls_line-received = lo_received->get( lv_key ).
      ls_line-difference = ls_line-received - ls_line-authorised.

      APPEND ls_line TO rt_lines.
    ENDLOOP.
  ENDMETHOD.

  METHOD total.
    LOOP AT it_lines INTO DATA(ls_line).
      rv_total = rv_total + ls_line-received.
    ENDLOOP.
  ENDMETHOD.

  METHOD short_lines.
    LOOP AT it_lines INTO DATA(ls_line).
      IF ls_line-difference < 0.
        rv_count = rv_count + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
