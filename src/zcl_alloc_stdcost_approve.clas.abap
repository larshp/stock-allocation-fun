CLASS zcl_alloc_stdcost_approve DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             version  TYPE string,
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
        iv_version   TYPE string
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS pending_count
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_stdcost_approve IMPLEMENTATION.

  METHOD approve.
    " Approving the standard cost marks every version as approved.
    rt_lines = it_lines.
    LOOP AT rt_lines ASSIGNING FIELD-SYMBOL(<ls_line>).
      <ls_line>-approved = abap_true.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_approved.
    " A version is approved once its mark is set.
    LOOP AT it_lines INTO DATA(ls_line).
      IF ls_line-version = iv_version AND ls_line-approved = abap_true.
        rv_ok = abap_true.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD pending_count.
    " The count gathers the versions still awaiting approval.
    LOOP AT it_lines INTO DATA(ls_line).
      IF ls_line-approved = abap_false.
        rv_count = rv_count + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
