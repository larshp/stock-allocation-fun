CLASS zcl_stock_goods_issue_sap DEFINITION PUBLIC INHERITING FROM zcl_stock_goods_issue_base CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_stock_goods_issue.
ENDCLASS.

CLASS zcl_stock_goods_issue_sap IMPLEMENTATION.
  METHOD zif_stock_goods_issue~create.
    IF cost_center IS INITIAL
        OR ( test_run <> abap_true AND test_run <> abap_false ).
      RAISE EXCEPTION TYPE zcx_stock_alloc
        EXPORTING reason = 'Cost center and valid test mode are required for goods issue'.
    ENDIF.
    zcl_stock_alloc_date=>validate( posting_date ).
    zcl_stock_alloc_date=>validate( document_date ).
    zcl_stock_alloc_result=>validate( allocations ).
    zcl_stock_alloc_origin=>require_independent( allocations ).
    DATA(header) = VALUE bapi2017_gm_head_01( pstng_date = posting_date
                                            doc_date     = document_date ).
    DATA(code) = VALUE bapi2017_gm_code( gm_code = '03' ).
    DATA items TYPE ty_items.
    LOOP AT allocations INTO DATA(allocation).
      IF allocation-allocated = 0.
        CONTINUE.
      ENDIF.
      " Movement 201: unrestricted stock to cost center, no reservation reference.
      APPEND VALUE #( material   = allocation-material
                      plant      = allocation-plant
                      stge_loc   = allocation-storage
                      move_type  = '201'
                      entry_qnt  = allocation-allocated
                      entry_uom  = allocation-unit
                      costcenter = cost_center ) TO items.
    ENDLOOP.
    IF items IS INITIAL.
      RAISE EXCEPTION TYPE zcx_stock_alloc
        EXPORTING reason = 'No allocated quantity to issue'.
    ENDIF.
    result = post( header     = header
                     code     = code
                     items    = items
                     test_run = test_run ).
  ENDMETHOD.
ENDCLASS.
