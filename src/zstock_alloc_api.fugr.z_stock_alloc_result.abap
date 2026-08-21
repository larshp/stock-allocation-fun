FUNCTION z_stock_alloc_result.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_WERKS) TYPE  MARD-WERKS
*"     VALUE(IV_VBELN) TYPE  VBAP-VBELN
*"     VALUE(IV_POSNR) TYPE  VBAP-POSNR OPTIONAL
*"  EXPORTING
*"     VALUE(ET_LINE) TYPE  ZCL_ALLOC_RESULT_API=>TY_LINE_TAB
*"     VALUE(ES_RETURN) TYPE  BAPIRET2
*"----------------------------------------------------------------------

* what the last run gave one order, for a caller that cannot read the table
* and cannot catch an exception. It reads and answers, so it needs no commit
* and no lock, and it holds no logic of its own.
*
* declared explicitly: an inline DATA() in a function module body is never
* declared in the transpiled output, see ANOMALIES.md
  DATA ls_answer TYPE zcl_alloc_result_api=>ty_answer.

  ls_answer = zcl_alloc_result_api=>result(
    iv_werks = iv_werks
    iv_vbeln = iv_vbeln
    iv_posnr = iv_posnr ).

  et_line   = ls_answer-line.
  es_return = ls_answer-message.

ENDFUNCTION.
