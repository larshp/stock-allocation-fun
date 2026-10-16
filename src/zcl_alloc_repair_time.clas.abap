CLASS zcl_alloc_repair_time DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_job,
             start_min TYPE i,
             end_min   TYPE i,
           END OF ty_job.
    TYPES ty_job_tt TYPE STANDARD TABLE OF ty_job WITH DEFAULT KEY.

    METHODS elapsed
      IMPORTING
        iv_start      TYPE i
        iv_end        TYPE i
      RETURNING
        VALUE(rv_min) TYPE i.

    METHODS average
      IMPORTING
        it_jobs       TYPE ty_job_tt
      RETURNING
        VALUE(rv_avg) TYPE i.

    METHODS is_on_target
      IMPORTING
        iv_minutes   TYPE i
        iv_target    TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_repair_time IMPLEMENTATION.

  METHOD elapsed.
    " A job that ends before it starts contributes no time.
    IF iv_end <= iv_start.
      RETURN.
    ENDIF.

    rv_min = iv_end - iv_start.
  ENDMETHOD.

  METHOD average.
    DATA lv_total TYPE i.
    DATA lv_count TYPE i.

    LOOP AT it_jobs INTO DATA(ls_job).
      lv_total = lv_total + elapsed( iv_start = ls_job-start_min
                                     iv_end   = ls_job-end_min ).
      lv_count = lv_count + 1.
    ENDLOOP.

    IF lv_count = 0.
      RETURN.
    ENDIF.

    rv_avg = lv_total DIV lv_count.
  ENDMETHOD.

  METHOD is_on_target.
    rv_ok = xsdbool( iv_target > 0 AND iv_minutes <= iv_target ).
  ENDMETHOD.

ENDCLASS.
