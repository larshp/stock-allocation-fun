CLASS zcl_job_scheduler DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_job_scheduler.

    "! What the jobs of a plant are called, before the plant and the package
    "! are put on the end. Everything a plant schedules this way sorts
    "! together in SM37, which is how somebody finds out at eight in the
    "! morning whether the night finished.
    CONSTANTS c_prefix TYPE c LENGTH 12 VALUE 'ZSTOCK_ALLOC'.

    "! The program the jobs run, which is the one a person would run by hand.
    CONSTANTS c_report TYPE sy-repid VALUE 'ZSTOCK_ALLOCATION'.

ENDCLASS.


CLASS zcl_job_scheduler IMPLEMENTATION.

  METHOD zif_job_scheduler~schedule.

    DATA lv_jobcount TYPE btcjobcnt.
    DATA lv_released TYPE abap_bool.
    DATA lv_jobname  TYPE btcjob.

    lv_jobname = |{ c_prefix }_{ iv_werks }_{ iv_package }|.

    CALL FUNCTION 'JOB_OPEN'
      EXPORTING
        jobname          = lv_jobname
      IMPORTING
        jobcount         = lv_jobcount
      EXCEPTIONS
        cant_create_job  = 1
        invalid_job_data = 2
        OTHERS           = 3.
    IF sy-subrc <> 0.
      RAISE EXCEPTION NEW zcx_allocation(
        textid     = zcx_allocation=>job_failed
        mv_message = |{ lv_jobname }| ).
    ENDIF.

    " the job runs the same program a person would run by hand, with the
    " package it covers and how many are sharing the plant. Everything else it
    " reads from the plant's Customizing, which is what P_CFG defaults to.
    SUBMIT (c_report)
      WITH p_werks = iv_werks
      WITH p_pkg   = iv_package
      WITH p_pkgs  = iv_packages
      WITH p_test  = iv_test
      WITH p_recut = iv_recut
      VIA JOB lv_jobname NUMBER lv_jobcount
      AND RETURN.

    CALL FUNCTION 'JOB_CLOSE'
      EXPORTING
        jobcount             = lv_jobcount
        jobname              = lv_jobname
        strtimmed            = abap_true
      IMPORTING
        job_was_released     = lv_released
      EXCEPTIONS
        cant_start_immediate = 1
        jobname_missing      = 2
        job_close_failed     = 3
        job_nosteps          = 4
        OTHERS               = 5.
    IF sy-subrc <> 0 OR lv_released = abap_false.
      RAISE EXCEPTION NEW zcx_allocation(
        textid     = zcx_allocation=>job_failed
        mv_message = |{ lv_jobname }| ).
    ENDIF.

    rv_jobname = lv_jobname.

  ENDMETHOD.

ENDCLASS.
