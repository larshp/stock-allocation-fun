CLASS zcl_alloc_return_approval DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_step,
             approver TYPE string,
             approved TYPE abap_bool,
           END OF ty_step.
    TYPES ty_step_tt TYPE STANDARD TABLE OF ty_step WITH DEFAULT KEY.

    METHODS approve
      IMPORTING
        it_steps        TYPE ty_step_tt
        iv_approver     TYPE string
      RETURNING
        VALUE(rt_steps) TYPE ty_step_tt.

    METHODS is_approved
      IMPORTING
        it_steps     TYPE ty_step_tt
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS pending_count
      IMPORTING
        it_steps        TYPE ty_step_tt
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_return_approval IMPLEMENTATION.

  METHOD approve.
    DATA ls_step TYPE ty_step.

    " The named approver signs their step; the other steps are left untouched.
    LOOP AT it_steps INTO DATA(ls_in).
      CLEAR ls_step.
      ls_step = ls_in.

      IF iv_approver IS NOT INITIAL
         AND ls_in-approver = iv_approver.
        ls_step-approved = abap_true.
      ENDIF.

      APPEND ls_step TO rt_steps.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_approved.
    DATA lv_count TYPE i.
    DATA lv_done  TYPE i.

    LOOP AT it_steps INTO DATA(ls_step).
      lv_count = lv_count + 1.
      IF ls_step-approved = abap_true.
        lv_done = lv_done + 1.
      ENDIF.
    ENDLOOP.

    " Nothing to sign is not an approval.
    rv_ok = xsdbool( lv_count > 0 AND lv_done = lv_count ).
  ENDMETHOD.

  METHOD pending_count.
    LOOP AT it_steps INTO DATA(ls_step).
      IF ls_step-approved = abap_false.
        rv_count = rv_count + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
