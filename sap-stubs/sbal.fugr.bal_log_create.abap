FUNCTION bal_log_create.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_S_LOG) TYPE  BAL_S_LOG
*"  EXPORTING
*"     VALUE(E_LOG_HANDLE) TYPE  BALLOGHNDL
*"  EXCEPTIONS
*"      LOG_HEADER_INCONSISTENT
*"----------------------------------------------------------------------

* declared explicitly: an inline DATA() in a function module body is never
* declared in the transpiled output, see ANOMALIES.md
  DATA lv_handle TYPE balloghndl.

  lv_handle = cl_stub_bal=>create( i_s_log ).

  IF lv_handle IS INITIAL.
    RAISE log_header_inconsistent.
  ENDIF.

  e_log_handle = lv_handle.

ENDFUNCTION.
