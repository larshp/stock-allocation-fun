CLASS zcl_alloc_gov_approve DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             key      TYPE string,
             approved TYPE abap_bool,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    METHODS approve
      IMPORTING
        it_lines        TYPE ty_line_tt
        iv_key          TYPE string
      RETURNING
        VALUE(rt_lines) TYPE ty_line_tt.

    METHODS is_approved
      IMPORTING
        it_lines     TYPE ty_line_tt
        iv_key       TYPE string
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS pending_count
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_gov_approve IMPLEMENTATION.

  METHOD approve.
    DATA ls_out TYPE ty_line.

    " The named item is approved in the returned list.
    LOOP AT it_lines INTO DATA(ls_in).
      CLEAR ls_out.
      ls_out-key = ls_in-key.
      ls_out-approved = ls_in-approved.
      IF ls_in-key = iv_key.
        ls_out-approved = abap_true.
      ENDIF.
      APPEND ls_out TO rt_lines.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_approved.
    " The item is approved once its flag is set.
    LOOP AT it_lines INTO DATA(ls_line).
      IF ls_line-key = iv_key AND ls_line-approved = abap_true.
        rv_ok = abap_true.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD pending_count.
    " The pending count gathers the items not yet approved.
    LOOP AT it_lines INTO DATA(ls_line).
      IF ls_line-approved = abap_false.
        rv_count = rv_count + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
