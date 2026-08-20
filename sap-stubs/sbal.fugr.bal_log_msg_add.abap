FUNCTION bal_log_msg_add.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_LOG_HANDLE) TYPE  BALLOGHNDL
*"     VALUE(I_S_MSG) TYPE  BAL_S_MSG
*"  EXCEPTIONS
*"      LOG_NOT_FOUND
*"      MSG_INCONSISTENT
*"      LOG_IS_FULL
*"----------------------------------------------------------------------

* declared explicitly: an inline DATA() in a function module body is never
* declared in the transpiled output, see ANOMALIES.md
  DATA lv_added TYPE abap_bool.

  IF i_s_msg-msgid IS INITIAL OR i_s_msg-msgty IS INITIAL.
    RAISE msg_inconsistent.
  ENDIF.

  lv_added = cl_stub_bal=>add_message(
    iv_handle = i_log_handle
    is_msg    = i_s_msg ).

  IF lv_added = abap_false.
    RAISE log_not_found.
  ENDIF.

ENDFUNCTION.
