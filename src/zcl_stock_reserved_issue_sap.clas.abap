CLASS zcl_stock_reserved_issue_sap DEFINITION PUBLIC INHERITING FROM zcl_stock_goods_issue_base CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_stock_reserved_issue.
ENDCLASS.

CLASS zcl_stock_reserved_issue_sap IMPLEMENTATION.
  METHOD zif_stock_reserved_issue~create.
    IF test_run <> abap_true AND test_run <> abap_false.
      RAISE EXCEPTION TYPE zcx_stock_alloc
        EXPORTING reason = 'A valid test mode is required for reserved goods issue'.
    ENDIF.
    zcl_stock_alloc_date=>validate( posting_date ).
    zcl_stock_alloc_date=>validate( document_date ).
    zcl_stock_alloc_result=>validate( allocations ).
    zcl_stock_alloc_origin=>require_reserved( allocations ).
    DATA items TYPE ty_items.
    LOOP AT allocations INTO DATA(allocation).
      IF allocation-allocated = 0.
        CONTINUE.
      ENDIF.
      " SAP derives material, plant, movement type and account assignment from the reference.
      APPEND VALUE #( reserv_no = allocation-origin-reservation
                      res_item  = allocation-origin-reservation_item
                      res_type  = allocation-origin-reservation_type
                      stge_loc  = allocation-storage
                      entry_qnt = allocation-allocated
                      entry_uom = allocation-unit ) TO items.
    ENDLOOP.
    IF items IS INITIAL.
      RAISE EXCEPTION TYPE zcx_stock_alloc
        EXPORTING reason = 'No allocated quantity to issue'.
    ENDIF.
    result = post( header   = VALUE #( pstng_date = posting_date doc_date = document_date )
                   code     = VALUE #( gm_code = '03' )
                   items    = items
                   test_run = test_run ).
  ENDMETHOD.
ENDCLASS.
