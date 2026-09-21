INTERFACE zif_source_read_authority PUBLIC.
  METHODS check_stock
    IMPORTING
      iv_plant TYPE zif_stock_allocation=>ty_plant
      iv_batch TYPE zif_stock_allocation=>ty_batch OPTIONAL
    RAISING
      zcx_stock_allocation.
  METHODS check_orders
    RAISING
      zcx_stock_allocation.
  METHODS check_sales_document
    IMPORTING
      iv_document_type        TYPE zif_stock_allocation=>ty_sales_document_type
      iv_sales_organization   TYPE vbak-vkorg
      iv_distribution_channel TYPE vbak-vtweg
      iv_division             TYPE vbak-spart
    RAISING
      zcx_stock_allocation.
ENDINTERFACE.
