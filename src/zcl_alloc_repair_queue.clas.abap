CLASS zcl_alloc_repair_queue DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_job,
             job_id   TYPE string,
             priority TYPE i,
             arrival  TYPE i,
           END OF ty_job.
    TYPES ty_job_tt TYPE STANDARD TABLE OF ty_job WITH DEFAULT KEY.

    METHODS sequence
      IMPORTING
        it_jobs        TYPE ty_job_tt
      RETURNING
        VALUE(rt_jobs) TYPE ty_job_tt.

    METHODS position_of
      IMPORTING
        it_jobs       TYPE ty_job_tt
        iv_job_id     TYPE string
      RETURNING
        VALUE(rv_pos) TYPE i.

    METHODS priority_order
      IMPORTING
        iv_priority    TYPE i
      RETURNING
        VALUE(rv_band) TYPE string.

  PRIVATE SECTION.
    TYPES: BEGIN OF ty_work,
             job_id   TYPE string,
             priority TYPE i,
             arrival  TYPE i,
             seq      TYPE i,
           END OF ty_work.
    TYPES ty_work_tt TYPE STANDARD TABLE OF ty_work WITH DEFAULT KEY.

    METHODS ranked
      IMPORTING
        it_jobs        TYPE ty_job_tt
      RETURNING
        VALUE(rt_work) TYPE ty_work_tt.

ENDCLASS.


CLASS zcl_alloc_repair_queue IMPLEMENTATION.

  METHOD ranked.
    DATA ls_work TYPE ty_work.
    DATA lv_seq  TYPE i.

    LOOP AT it_jobs INTO DATA(ls_job).
      CLEAR ls_work.
      lv_seq = lv_seq + 1.
      ls_work-job_id = ls_job-job_id.
      ls_work-priority = ls_job-priority.
      ls_work-arrival = ls_job-arrival.
      ls_work-seq = lv_seq.
      APPEND ls_work TO rt_work.
    ENDLOOP.

    " Highest priority first, then the earliest arrival, then the input order, so
    " the sort is stable.
    SORT rt_work BY priority DESCENDING
                    arrival  ASCENDING
                    seq      ASCENDING.
  ENDMETHOD.

  METHOD sequence.
    DATA lt_work TYPE ty_work_tt.
    DATA ls_job  TYPE ty_job.

    lt_work = ranked( it_jobs ).

    LOOP AT lt_work INTO DATA(ls_work).
      CLEAR ls_job.
      ls_job-job_id = ls_work-job_id.
      ls_job-priority = ls_work-priority.
      ls_job-arrival = ls_work-arrival.
      APPEND ls_job TO rt_jobs.
    ENDLOOP.
  ENDMETHOD.

  METHOD position_of.
    DATA lt_work TYPE ty_work_tt.
    DATA lv_pos  TYPE i.

    lt_work = ranked( it_jobs ).

    LOOP AT lt_work INTO DATA(ls_work).
      lv_pos = lv_pos + 1.

      IF ls_work-job_id = iv_job_id.
        rv_pos = lv_pos.
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD priority_order.
    IF iv_priority >= 8.
      rv_band = 'HIGH'.
    ELSEIF iv_priority >= 4.
      rv_band = 'MEDIUM'.
    ELSE.
      rv_band = 'LOW'.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
