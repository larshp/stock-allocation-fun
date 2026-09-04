FUNCTION bal_db_save.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"     IMPORTING
*"             VALUE(I_T_LOG_HANDLE) TYPE  BAL_T_LOGH
*"             VALUE(I_SAVE_ALL) TYPE  ABAP_BOOL DEFAULT SPACE
*"     EXCEPTIONS
*"             LOG_NOT_FOUND
*"             SAVE_NOT_ALLOWED
*"             NUMBERING_ERROR
*"----------------------------------------------------------------------

* the real function module writes BALHDR and BALDAT on the update task, and
* nothing here reads them back. What the custom code depends on is that a
* handle nobody opened cannot be saved.
  DATA lv_handle TYPE balloghndl.
  DATA lv_saved  TYPE abap_bool.

  LOOP AT i_t_log_handle INTO lv_handle.

    lv_saved = cl_stub_bal=>save( lv_handle ).

    IF lv_saved = abap_false.
      RAISE log_not_found.
    ENDIF.

  ENDLOOP.

ENDFUNCTION.
