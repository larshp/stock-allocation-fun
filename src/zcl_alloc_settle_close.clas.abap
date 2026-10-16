CLASS zcl_alloc_settle_close DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             order_id TYPE string,
             closed   TYPE abap_bool,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    METHODS close_out
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rt_lines) TYPE ty_line_tt.

    METHODS is_closed
      IMPORTING
        it_lines     TYPE ty_line_tt
        iv_order     TYPE string
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS open_count
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_settle_close IMPLEMENTATION.

  METHOD close_out.
    " Closing the period marks every order as closed.
    rt_lines = it_lines.
    LOOP AT rt_lines ASSIGNING FIELD-SYMBOL(<ls_line>).
      <ls_line>-closed = abap_true.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_closed.
    " An order is closed once its mark is set.
    LOOP AT it_lines INTO DATA(ls_line).
      IF ls_line-order_id = iv_order AND ls_line-closed = abap_true.
        rv_ok = abap_true.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD open_count.
    " The count gathers the orders still open.
    LOOP AT it_lines INTO DATA(ls_line).
      IF ls_line-closed = abap_false.
        rv_count = rv_count + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
