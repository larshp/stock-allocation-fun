FUNCTION bapi_reservation_create1.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(RESERVATIONHEADER) TYPE  BAPI2093_RES_HEAD
*"  EXPORTING
*"     VALUE(RESERVATION) TYPE  RKPF-RSNUM
*"  TABLES
*"      RESERVATIONITEMS STRUCTURE  BAPI2093_RES_ITEM
*"      RETURN STRUCTURE  BAPIRET2
*"----------------------------------------------------------------------

  DATA lt_item TYPE cl_stub_reservation=>ty_item_tab.

  lt_item = reservationitems[].

  DATA(ls_result) = cl_stub_reservation=>create(
    is_header = reservationheader
    it_item   = lt_item ).

  reservation = ls_result-reservation.
  return[] = ls_result-messages.

ENDFUNCTION.
