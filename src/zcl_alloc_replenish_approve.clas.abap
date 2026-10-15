CLASS zcl_alloc_replenish_approve DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             material TYPE matnr,
             approved TYPE abap_bool,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    METHODS approve
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rt_lines) TYPE ty_line_tt.

    METHODS is_approved
      IMPORTING
        it_lines     TYPE ty_line_tt
        iv_material  TYPE matnr
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS pending_count
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_replenish_approve IMPLEMENTATION.

  METHOD approve.
    DATA ls_out TYPE ty_line.

    " Approval marks every line as approved.
    LOOP AT it_lines INTO DATA(ls_line).
      ls_out = ls_line.
      ls_out-approved = abap_true.
      APPEND ls_out TO rt_lines.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_approved.
    LOOP AT it_lines INTO DATA(ls_line).
      IF ls_line-material = iv_material.
        rv_ok = ls_line-approved.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD pending_count.
    " A line is pending while it is not approved yet.
    LOOP AT it_lines INTO DATA(ls_line).
      IF ls_line-approved = abap_false.
        rv_count = rv_count + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
