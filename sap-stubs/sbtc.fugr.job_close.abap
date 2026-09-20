FUNCTION job_close.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(JOBCOUNT) TYPE  BTCJOBCNT
*"     VALUE(JOBNAME) TYPE  BTCJOB
*"     VALUE(STRTIMMED) TYPE  ABAP_BOOL
*"  EXPORTING
*"     VALUE(JOB_WAS_RELEASED) TYPE  ABAP_BOOL
*"  EXCEPTIONS
*"      CANT_START_IMMEDIATE
*"      JOBNAME_MISSING
*"      JOB_CLOSE_FAILED
*"      JOB_NOSTEPS
*"----------------------------------------------------------------------

  IF jobname IS INITIAL.
    RAISE jobname_missing.
  ENDIF.

  job_was_released = cl_stub_job=>close(
    iv_jobname   = jobname
    iv_jobcount  = jobcount
    iv_immediate = strtimmed ).

ENDFUNCTION.
