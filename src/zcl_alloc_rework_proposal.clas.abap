CLASS zcl_alloc_rework_proposal DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_step,
             step  TYPE string,
             hours TYPE i,
           END OF ty_step.
    TYPES ty_step_tt TYPE STANDARD TABLE OF ty_step WITH DEFAULT KEY.

    METHODS propose
      IMPORTING
        iv_grade        TYPE string
      RETURNING
        VALUE(rt_steps) TYPE ty_step_tt.

    METHODS total_hours
      IMPORTING
        it_steps        TYPE ty_step_tt
      RETURNING
        VALUE(rv_hours) TYPE i.

    METHODS steps
      IMPORTING
        it_steps        TYPE ty_step_tt
      RETURNING
        VALUE(rv_count) TYPE i.

  PRIVATE SECTION.
    METHODS add_step
      IMPORTING
        iv_step  TYPE string
        iv_hours TYPE i
      CHANGING
        ct_steps TYPE ty_step_tt.

ENDCLASS.


CLASS zcl_alloc_rework_proposal IMPLEMENTATION.

  METHOD add_step.
    DATA ls_step TYPE ty_step.

    ls_step-step = iv_step.
    ls_step-hours = iv_hours.
    APPEND ls_step TO ct_steps.
  ENDMETHOD.

  METHOD propose.
    DATA lt_steps TYPE ty_step_tt.

    " The rework effort grows with the damage: a cosmetic grade C needs a clean
    " and a test, a grade D also needs a part replaced.
    CASE iv_grade.
      WHEN 'C'.
        add_step( EXPORTING iv_step  = 'CLEAN'
                            iv_hours = 1
                  CHANGING  ct_steps = lt_steps ).
        add_step( EXPORTING iv_step  = 'TEST'
                            iv_hours = 1
                  CHANGING  ct_steps = lt_steps ).
      WHEN 'D'.
        add_step( EXPORTING iv_step  = 'CLEAN'
                            iv_hours = 1
                  CHANGING  ct_steps = lt_steps ).
        add_step( EXPORTING iv_step  = 'REPLACE_PART'
                            iv_hours = 2
                  CHANGING  ct_steps = lt_steps ).
        add_step( EXPORTING iv_step  = 'TEST'
                            iv_hours = 1
                  CHANGING  ct_steps = lt_steps ).
    ENDCASE.

    rt_steps = lt_steps.
  ENDMETHOD.

  METHOD total_hours.
    LOOP AT it_steps INTO DATA(ls_step).
      rv_hours = rv_hours + ls_step-hours.
    ENDLOOP.
  ENDMETHOD.

  METHOD steps.
    rv_count = lines( it_steps ).
  ENDMETHOD.

ENDCLASS.
