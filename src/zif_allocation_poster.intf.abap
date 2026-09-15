INTERFACE zif_allocation_poster
  PUBLIC.

  TYPES: BEGIN OF ty_posting_result,
           document_number TYPE bapi2017_gm_head_ret-mat_doc,
           document_year   TYPE bapi2017_gm_head_ret-doc_year,
           success         TYPE abap_bool,
         END OF ty_posting_result.

  METHODS post
    IMPORTING
      it_result        TYPE zcl_stock_allocator=>ty_result_tt
      iv_matnr         TYPE matnr
      iv_werks         TYPE werks_d
      iv_move_type     TYPE bapi2017_gm_item_create-move_type
    RETURNING
      VALUE(rs_result) TYPE ty_posting_result.

ENDINTERFACE.
