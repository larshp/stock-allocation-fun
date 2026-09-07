FUNCTION bapi_reservation_change.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(RESERVATION) TYPE  RKPF-RSNUM
*"  TABLES
*"      RESERVATIONITEMS STRUCTURE  BAPI2093_RES_ITEM_CHANGE
*"      RESERVATIONITEMSX STRUCTURE  BAPI2093_RES_ITEM_CHANGEX
*"      RETURN STRUCTURE  BAPIRET2
*"----------------------------------------------------------------------

* declared explicitly: an inline DATA() in a function module body is never
* declared in the transpiled output, see ANOMALIES.md
  DATA lt_item  TYPE cl_stub_reservation=>ty_change_tab.
  DATA lt_itemx TYPE cl_stub_reservation=>ty_changex_tab.

  lt_item  = reservationitems[].
  lt_itemx = reservationitemsx[].

  return[] = cl_stub_reservation=>change(
    iv_reservation = reservation
    it_item        = lt_item
    it_itemx       = lt_itemx ).

ENDFUNCTION.
