CLASS zcl_alloc_cursor DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_input,
             total     TYPE i,
             page_size TYPE i,
           END OF ty_input.

    TYPES: BEGIN OF ty_cursor,
             offset    TYPE i,
             page_size TYPE i,
             total     TYPE i,
           END OF ty_cursor.

    METHODS open
      IMPORTING
        is_input         TYPE ty_input
      RETURNING
        VALUE(rs_cursor) TYPE ty_cursor.

    METHODS next
      IMPORTING
        is_cursor        TYPE ty_cursor
      RETURNING
        VALUE(rs_cursor) TYPE ty_cursor.

    METHODS is_last
      IMPORTING
        is_cursor      TYPE ty_cursor
      RETURNING
        VALUE(rv_last) TYPE abap_bool.

    METHODS remaining
      IMPORTING
        is_cursor       TYPE ty_cursor
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_cursor IMPLEMENTATION.

  METHOD open.
    rs_cursor-total = is_input-total.
    rs_cursor-page_size = is_input-page_size.
    IF rs_cursor-page_size < 1.
      rs_cursor-page_size = is_input-total.
    ENDIF.
    rs_cursor-offset = 0.
  ENDMETHOD.

  METHOD next.
    rs_cursor = is_cursor.

    IF rs_cursor-page_size < 1.
      rs_cursor-offset = rs_cursor-total.
      RETURN.
    ENDIF.

    rs_cursor-offset = rs_cursor-offset + rs_cursor-page_size.
    IF rs_cursor-offset > rs_cursor-total.
      rs_cursor-offset = rs_cursor-total.
    ENDIF.
  ENDMETHOD.

  METHOD is_last.
    rv_last = abap_false.

    IF is_cursor-offset >= is_cursor-total.
      rv_last = abap_true.
      RETURN.
    ENDIF.

    IF is_cursor-page_size < 1.
      rv_last = abap_true.
      RETURN.
    ENDIF.

    IF is_cursor-offset + is_cursor-page_size >= is_cursor-total.
      rv_last = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD remaining.
    rv_count = is_cursor-total - is_cursor-offset.
    IF rv_count < 0.
      rv_count = 0.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
