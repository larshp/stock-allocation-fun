CLASS zcl_alloc_sched_spt DEFINITION
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
             late_days  TYPE i,
             is_late    TYPE abap_bool,
           END OF ty_slot.
    TYPES ty_slot_tt TYPE STANDARD TABLE OF ty_slot WITH DEFAULT KEY.

    METHODS schedule
      IMPORTING
        it_jobs         TYPE ty_job_tt
      RETURNING
        VALUE(rt_slots) TYPE ty_slot_tt.

    METHODS late_count
      IMPORTING
        it_slots       TYPE ty_slot_tt
      RETURNING
        VALUE(rv_late) TYPE i.

    METHODS avg_finish
      IMPORTING
        it_slots      TYPE ty_slot_tt
      RETURNING
        VALUE(rv_avg) TYPE i.

ENDCLASS.


CLASS zcl_alloc_sched_spt IMPLEMENTATION.

  METHOD schedule.
    DATA lt_jobs TYPE ty_job_tt.
    DATA ls_slot TYPE ty_slot.
    DATA lv_day  TYPE i.

    lt_jobs = it_jobs.
    SORT lt_jobs BY work_time ASCENDING.

    LOOP AT lt_jobs INTO DATA(ls_job).
      CLEAR ls_slot.
      ls_slot-job_id = ls_job-job_id.
      ls_slot-start_day = lv_day.
      ls_slot-due_day = ls_job-due_day.

      lv_day = lv_day + ls_job-work_time.
      ls_slot-finish_day = lv_day.

      IF ls_slot-finish_day > ls_job-due_day.
        ls_slot-late_days = ls_slot-finish_day - ls_job-due_day.
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

  METHOD avg_finish.
    DATA lv_sum   TYPE i.
    DATA lv_count TYPE i.

    lv_count = lines( it_slots ).
    IF lv_count = 0.
      RETURN.
    ENDIF.

    LOOP AT it_slots INTO DATA(ls_slot).
      lv_sum = lv_sum + ls_slot-finish_day.
    ENDLOOP.

    rv_avg = lv_sum DIV lv_count.
  ENDMETHOD.

ENDCLASS.
