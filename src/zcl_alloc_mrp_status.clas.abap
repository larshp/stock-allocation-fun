CLASS zcl_alloc_mrp_status DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_step,
             step TYPE string,
             done TYPE abap_bool,
           END OF ty_step.
    TYPES ty_step_tt TYPE STANDARD TABLE OF ty_step WITH DEFAULT KEY.

    METHODS status
      IMPORTING
        it_steps         TYPE ty_step_tt
      RETURNING
        VALUE(rv_status) TYPE string.

    METHODS is_complete
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


CLASS zcl_alloc_mrp_status IMPLEMENTATION.

  METHOD status.
    DATA lv_total TYPE i.
    DATA lv_done  TYPE i.

    " The run is complete once every step is done, running while some are, open
    " while none are, and empty when there are no steps.
    LOOP AT it_steps INTO DATA(ls_step).
      lv_total = lv_total + 1.
      IF ls_step-done = abap_true.
        lv_done = lv_done + 1.
      ENDIF.
    ENDLOOP.

    IF lv_total <= 0.
      rv_status = 'EMPTY'.
    ELSEIF lv_done >= lv_total.
      rv_status = 'COMPLETE'.
    ELSEIF lv_done > 0.
      rv_status = 'RUNNING'.
    ELSE.
      rv_status = 'OPEN'.
    ENDIF.
  ENDMETHOD.

  METHOD is_complete.
    DATA lv_total TYPE i.
    DATA lv_done  TYPE i.

    " A run is complete only when it has steps and all of them are done.
    LOOP AT it_steps INTO DATA(ls_step).
      lv_total = lv_total + 1.
      IF ls_step-done = abap_true.
        lv_done = lv_done + 1.
      ENDIF.
    ENDLOOP.

    rv_ok = xsdbool( lv_total > 0 AND lv_done >= lv_total ).
  ENDMETHOD.

  METHOD pending_count.
    " A pending step is one that is not done yet.
    LOOP AT it_steps INTO DATA(ls_step).
      IF ls_step-done = abap_false.
        rv_count = rv_count + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
