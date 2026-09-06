INTERFACE zif_stock_goods_issue PUBLIC.
  TYPES: BEGIN OF ty_result,
           material_document TYPE bapi2017_gm_head_ret-mat_doc,
           document_year     TYPE bapi2017_gm_head_ret-doc_year,
           simulated         TYPE abap_bool,
           messages          TYPE zcx_stock_alloc=>ty_messages,
         END OF ty_result.
  METHODS create
    IMPORTING allocations   TYPE zif_stock_alloc_types=>ty_allocations
              cost_center   TYPE bapi2017_gm_item_create-costcenter
              posting_date  TYPE d
              document_date TYPE d
              test_run      TYPE abap_bool DEFAULT abap_true
    RETURNING VALUE(result) TYPE ty_result
    RAISING zcx_stock_alloc.
ENDINTERFACE.
