INTERFACE zif_stock_reserved_issue PUBLIC.
  TYPES ty_result TYPE zif_stock_goods_issue=>ty_result.
  METHODS create
    IMPORTING allocations   TYPE zif_stock_alloc_types=>ty_allocations
              posting_date  TYPE d
              document_date TYPE d
              test_run      TYPE abap_bool DEFAULT abap_true
    RETURNING VALUE(result) TYPE ty_result
    RAISING zcx_stock_alloc.
ENDINTERFACE.
