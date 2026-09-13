CLASS zcl_allocation_poster_bapi DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_allocation_poster.

  PRIVATE SECTION.
    TYPES ty_item_tt TYPE STANDARD TABLE OF bapi2017_gm_item_create
      WITH DEFAULT KEY.

    METHODS build_items
      IMPORTING
        it_result       TYPE zcl_stock_allocator=>ty_result_tt
        iv_matnr        TYPE matnr
        iv_werks        TYPE werks_d
        iv_move_type    TYPE bapi2017_gm_item_create-move_type
      RETURNING
        VALUE(rt_items) TYPE ty_item_tt.

ENDCLASS.


CLASS zcl_allocation_poster_bapi IMPLEMENTATION.

  METHOD zif_allocation_poster~post.
    DATA ls_header  TYPE bapi2017_gm_head_01.
    DATA ls_code    TYPE bapi2017_gm_code.
    DATA ls_headret TYPE bapi2017_gm_head_ret.
    DATA lt_items   TYPE ty_item_tt.

    lt_items = build_items( it_result    = it_result
                            iv_matnr     = iv_matnr
                            iv_werks     = iv_werks
                            iv_move_type = iv_move_type ).

    IF lt_items IS INITIAL.
      RETURN.
    ENDIF.

    ls_header-pstng_date = sy-datum.
    ls_header-doc_date   = sy-datum.
    ls_code-gm_code      = '04'.

    CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
      EXPORTING
        header           = ls_header
        goodsmvt_code    = ls_code
      IMPORTING
        goodsmvt_headret = ls_headret
      TABLES
        goodsmvt_item    = lt_items.

    rs_result-document_number = ls_headret-mat_doc.
    rs_result-document_year   = ls_headret-doc_year.

    IF ls_headret-mat_doc IS NOT INITIAL.
      rs_result-success = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD build_items.
    LOOP AT it_result INTO DATA(ls_result).
      LOOP AT ls_result-allocations INTO DATA(ls_allocation).
        APPEND VALUE #( material  = iv_matnr
                        plant     = iv_werks
                        stge_loc  = ls_allocation-lgort
                        move_type = iv_move_type
                        entry_qnt = ls_allocation-quantity ) TO rt_items.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
