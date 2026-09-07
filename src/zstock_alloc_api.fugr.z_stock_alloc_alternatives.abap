FUNCTION z_stock_alloc_alternatives.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_MATNR) TYPE  MARD-MATNR
*"     VALUE(IV_WERKS) TYPE  MARD-WERKS
*"     VALUE(IV_QUANTITY) TYPE  ZSTOCK_ALLOC_PROMISE-QUANTITY
*"     VALUE(IV_BY_DATE) TYPE  ZSTOCK_ALLOC_PROMISE-AVAIL_DATE OPTIONAL
*"  EXPORTING
*"     VALUE(ET_ANSWER) TYPE  ZCL_ALLOC_ALT_API=>TY_ANSWER_TAB
*"----------------------------------------------------------------------

* what else the plant could promise when the material asked for is short.
* It reads and answers, so it needs no commit and no lock, and it holds no
* logic of its own.

  et_answer = zcl_alloc_alt_api=>alternatives(
    iv_matnr    = iv_matnr
    iv_werks    = iv_werks
    iv_quantity = iv_quantity
    iv_by_date  = iv_by_date ).

ENDFUNCTION.
