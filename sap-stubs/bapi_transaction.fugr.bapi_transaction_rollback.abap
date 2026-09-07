FUNCTION bapi_transaction_rollback.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  EXPORTING
*"     VALUE(RETURN) TYPE  BAPIRET2
*"----------------------------------------------------------------------

  ROLLBACK WORK.

  CLEAR return.

ENDFUNCTION.
