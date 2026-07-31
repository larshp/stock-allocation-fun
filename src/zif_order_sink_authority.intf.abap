INTERFACE zif_order_sink_authority PUBLIC.
  METHODS check
    IMPORTING
      iv_sales_document_type TYPE zif_order_sink=>ty_sales_document_type
    RAISING
      zcx_stock_allocation.
ENDINTERFACE.
