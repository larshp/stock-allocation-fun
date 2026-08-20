FUNCTION z_stock_alloc_promises.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  TABLES
*"      IT_ASK STRUCTURE  ZSTOCK_ALLOC_ASK
*"      ET_ANSWER STRUCTURE  ZSTOCK_ALLOC_ANS
*"----------------------------------------------------------------------

* a basket priced one line at a time is one round trip per line. The class
* below answers all of them, reading each plant's settings once.
*
* declared explicitly: an inline DATA() in a function module body is never
* declared in the transpiled output, see ANOMALIES.md
  DATA lt_ask TYPE zcl_alloc_atp_api=>ty_ask_tab.

  lt_ask = it_ask[].

  et_answer[] = zcl_alloc_atp_api=>promises( lt_ask ).

ENDFUNCTION.
