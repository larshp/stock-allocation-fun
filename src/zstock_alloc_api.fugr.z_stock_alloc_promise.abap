FUNCTION z_stock_alloc_promise.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_MATNR) TYPE  MARD-MATNR
*"     VALUE(IV_WERKS) TYPE  MARD-WERKS
*"     VALUE(IV_QUANTITY) TYPE  ZSTOCK_ALLOC_PROMISE-QUANTITY
*"     VALUE(IV_BY_DATE) TYPE  ZSTOCK_ALLOC_PROMISE-AVAIL_DATE OPTIONAL
*"     VALUE(IV_LGORT) TYPE  MARD-LGORT OPTIONAL
*"  EXPORTING
*"     VALUE(ES_PROMISE) TYPE  ZSTOCK_ALLOC_PROMISE
*"     VALUE(ES_RETURN) TYPE  BAPIRET2
*"----------------------------------------------------------------------

* the front door for anything outside this repository: a sales order user
* exit, a Fiori service, a system on the other end of an RFC destination. It
* reads and answers, so it needs no commit and no lock, and it holds no logic
* of its own -- the class below is the same answer for a caller in ABAP.
*
* declared explicitly: an inline DATA() in a function module body is never
* declared in the transpiled output, see ANOMALIES.md
  DATA ls_answer TYPE zcl_alloc_atp_api=>ty_answer.

  ls_answer = zcl_alloc_atp_api=>promise(
    iv_matnr    = iv_matnr
    iv_werks    = iv_werks
    iv_quantity = iv_quantity
    iv_by_date  = iv_by_date
    iv_lgort    = iv_lgort ).

  es_promise = ls_answer-promise.
  es_return  = ls_answer-message.

ENDFUNCTION.
