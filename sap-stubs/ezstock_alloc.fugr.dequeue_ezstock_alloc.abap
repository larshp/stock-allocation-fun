FUNCTION dequeue_ezstock_alloc.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(MODE_MARC) TYPE  ENQMODE DEFAULT 'E'
*"     VALUE(MANDT) TYPE  MARC-MANDT DEFAULT SY-MANDT
*"     VALUE(MATNR) TYPE  MARC-MATNR DEFAULT SPACE
*"     VALUE(WERKS) TYPE  MARC-WERKS DEFAULT SPACE
*"     VALUE(_SCOPE) TYPE  DDENQSCOPE DEFAULT '3'
*"----------------------------------------------------------------------

  cl_stub_enqueue=>release(
    iv_matnr = matnr
    iv_werks = werks ).

ENDFUNCTION.
