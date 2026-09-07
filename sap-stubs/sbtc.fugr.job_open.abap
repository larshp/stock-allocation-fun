FUNCTION job_open.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(JOBNAME) TYPE  BTCJOB
*"  EXPORTING
*"     VALUE(JOBCOUNT) TYPE  BTCJOBCNT
*"  EXCEPTIONS
*"      CANT_CREATE_JOB
*"      INVALID_JOB_DATA
*"----------------------------------------------------------------------

* declared explicitly: an inline DATA() in a function module body is never
* declared in the transpiled output, see ANOMALIES.md
  DATA lv_count TYPE btcjobcnt.

  IF jobname IS INITIAL.
    RAISE invalid_job_data.
  ENDIF.

  lv_count = cl_stub_job=>open( jobname ).

  jobcount = lv_count.

ENDFUNCTION.
