CLASS zcl_alloc_cutover DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_step,
             step_id   TYPE i,
             step_name TYPE string,
             owner     TYPE string,
             done      TYPE abap_bool,
           END OF ty_step.
    TYPES ty_step_tt TYPE STANDARD TABLE OF ty_step WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_checklist,
             total_steps  TYPE i,
             done_steps   TYPE i,
             open_steps   TYPE i,
             progress_pct TYPE i,
             ready        TYPE abap_bool,
           END OF ty_checklist.

    METHODS build
      IMPORTING
        it_steps            TYPE ty_step_tt
      RETURNING
        VALUE(rs_checklist) TYPE ty_checklist.

    METHODS open_steps
      IMPORTING
        it_steps       TYPE ty_step_tt
      RETURNING
        VALUE(rt_open) TYPE ty_step_tt.

ENDCLASS.


CLASS zcl_alloc_cutover IMPLEMENTATION.

  METHOD build.
    rs_checklist-total_steps = lines( it_steps ).

    LOOP AT it_steps INTO DATA(ls_step).
      IF ls_step-done = abap_true.
        rs_checklist-done_steps = rs_checklist-done_steps + 1.
      ENDIF.
    ENDLOOP.

    rs_checklist-open_steps = rs_checklist-total_steps - rs_checklist-done_steps.

    IF rs_checklist-total_steps > 0.
      rs_checklist-progress_pct =
        rs_checklist-done_steps * 100 DIV rs_checklist-total_steps.
    ENDIF.

    IF rs_checklist-open_steps = 0.
      rs_checklist-ready = abap_true.
    ELSE.
      rs_checklist-ready = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD open_steps.
    LOOP AT it_steps INTO DATA(ls_step).
      IF ls_step-done = abap_false.
        APPEND ls_step TO rt_open.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
