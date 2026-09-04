FUNCTION bapi_transaction_commit.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(WAIT) TYPE  BAPITA-WAIT DEFAULT SPACE
*"  EXPORTING
*"     VALUE(RETURN) TYPE  BAPIRET2
*"----------------------------------------------------------------------

  IF wait = abap_true.
    COMMIT WORK AND WAIT.
  ELSE.
    COMMIT WORK.
  ENDIF.

  CLEAR return.

ENDFUNCTION.
