FUNCTION enqueue_ezstock_alloc.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(MODE_MARC) TYPE  ENQMODE DEFAULT 'E'
*"     VALUE(MANDT) TYPE  MARC-MANDT DEFAULT SY-MANDT
*"     VALUE(MATNR) TYPE  MARC-MATNR DEFAULT SPACE
*"     VALUE(WERKS) TYPE  MARC-WERKS DEFAULT SPACE
*"     VALUE(_SCOPE) TYPE  DDENQSCOPE DEFAULT '2'
*"  EXCEPTIONS
*"      FOREIGN_LOCK
*"      SYSTEM_FAILURE
*"----------------------------------------------------------------------

* declared explicitly: an inline DATA() in a function module body is never
* declared in the transpiled output, see ANOMALIES.md
  DATA lv_granted TYPE abap_bool.

  lv_granted = cl_stub_enqueue=>acquire(
    iv_matnr = matnr
    iv_werks = werks ).

  IF lv_granted = abap_false.
    RAISE foreign_lock.
  ENDIF.

ENDFUNCTION.
