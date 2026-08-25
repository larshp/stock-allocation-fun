"! Pluggable stock sorting strategy for the allocation engine.
"! Implementations decide in which order storage locations are consumed.
INTERFACE zif_alloc_strategy PUBLIC.

  TYPES tt_mard TYPE STANDARD TABLE OF mard WITH DEFAULT KEY.

  "! Sort the stock rows into consumption order
  METHODS sort_stock
    IMPORTING
      it_mard        TYPE tt_mard
      iv_matnr       TYPE matnr
      iv_werks       TYPE werks_d
    RETURNING
      VALUE(rt_mard) TYPE tt_mard.

ENDINTERFACE.
