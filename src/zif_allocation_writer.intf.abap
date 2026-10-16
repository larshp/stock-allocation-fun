INTERFACE zif_allocation_writer
  PUBLIC.

  METHODS write
    IMPORTING
      iv_run_id         TYPE zstock_run_id
      iv_matnr          TYPE matnr
      iv_werks          TYPE werks_d
      it_result         TYPE zcl_stock_allocator=>ty_result_tt
    RETURNING
      VALUE(rv_written) TYPE i.

ENDINTERFACE.
