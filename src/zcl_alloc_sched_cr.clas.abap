CLASS zcl_alloc_sched_cr DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_job,
             job_id    TYPE string,
             work_time TYPE i,
             due_day   TYPE i,
           END OF ty_job.
    TYPES ty_job_tt TYPE STANDARD TABLE OF ty_job WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_slot,
             job_id     TYPE string,
             start_day  TYPE i,
             finish_day TYPE i,
             due_day    TYPE i,
             work_time  TYPE i,
             cr_x100    TYPE i,
             late_days  TYPE i,
             is_late    TYPE abap_bool,
           END OF ty_slot.
    TYPES ty_slot_tt TYPE STANDARD TABLE OF ty_slot WITH DEFAULT KEY.

    METHODS schedule
      IMPORTING
        it_jobs         TYPE ty_job_tt
        iv_today        TYPE i
      RETURNING
        VALUE(rt_slots) TYPE ty_slot_tt.

    METHODS late_count
      IMPORTING
        it_slots       TYPE ty_slot_tt
      RETURNING
        VALUE(rv_late) TYPE i.

  PRIVATE SECTION.
    METHODS cr_of
      IMPORTING
        is_job       TYPE ty_job
        iv_today     TYPE i
      RETURNING
        VALUE(rv_cr) TYPE i.

ENDCLASS.


CLASS zcl_alloc_sched_cr IMPLEMENTATION.

  METHOD cr_of.
    DATA lv_remaining TYPE i.

    IF is_job-work_time <= 0.
      RETURN.
    ENDIF.

    lv_remaining = is_job-due_day - iv_today.
    rv_cr = lv_remaining * 100 DIV is_job-work_time.
  ENDMETHOD.

  METHOD schedule.
    DATA lt_order TYPE ty_slot_tt.
    DATA ls_key   TYPE ty_slot.
    DATA ls_slot  TYPE ty_slot.
    DATA lv_day   TYPE i.

    " The critical ratio is the slack per unit of work, so the smallest ratio
    " is the most urgent job.
    LOOP AT it_jobs INTO DATA(ls_job).
      CLEAR ls_key.
      ls_key-job_id = ls_job-job_id.
      ls_key-due_day = ls_job-due_day.
      ls_key-work_time = ls_job-work_time.
      ls_key-cr_x100 = cr_of( is_job   = ls_job
                              iv_today = iv_today ).
      APPEND ls_key TO lt_order.
    ENDLOOP.

    SORT lt_order BY cr_x100 ASCENDING.

    LOOP AT lt_order INTO ls_key.
      CLEAR ls_slot.
      ls_slot-job_id = ls_key-job_id.
      ls_slot-due_day = ls_key-due_day.
      ls_slot-cr_x100 = ls_key-cr_x100.
      ls_slot-start_day = lv_day.

      lv_day = lv_day + ls_key-work_time.
      ls_slot-finish_day = lv_day.

      IF ls_slot-finish_day > ls_slot-due_day.
        ls_slot-late_days = ls_slot-finish_day - ls_slot-due_day.
        ls_slot-is_late = abap_true.
      ENDIF.

      APPEND ls_slot TO rt_slots.
    ENDLOOP.
  ENDMETHOD.

  METHOD late_count.
    LOOP AT it_slots INTO DATA(ls_slot).
      IF ls_slot-is_late = abap_true.
        rv_late = rv_late + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
