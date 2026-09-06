CLASS zcl_stock_goods_issue_sap DEFINITION PUBLIC CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_stock_goods_issue.
  PROTECTED SECTION.
    TYPES ty_items TYPE STANDARD TABLE OF bapi2017_gm_item_create WITH DEFAULT KEY.
    METHODS invoke
      IMPORTING header        TYPE bapi2017_gm_head_01
                code          TYPE bapi2017_gm_code
                items         TYPE ty_items
                test_run      TYPE abap_bool
      RETURNING VALUE(result) TYPE zif_stock_goods_issue=>ty_result.
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
    result = invoke( header   = header
                     code     = code
                     items    = items
                     test_run = test_run ).
    result-simulated = test_run.
    LOOP AT result-messages INTO DATA(message).
      IF message-type = 'E' OR message-type = 'A' OR message-type = 'X'.
        RAISE EXCEPTION TYPE zcx_stock_alloc
          EXPORTING reason   = |SAP goods issue failed: { message-id } { message-number } { message-message }|
                    messages = result-messages.
      ENDIF.
    ENDLOOP.
    IF test_run = abap_true.
      CLEAR: result-material_document, result-document_year.
    ELSEIF result-material_document IS INITIAL OR result-document_year IS INITIAL.
      RAISE EXCEPTION TYPE zcx_stock_alloc
        EXPORTING reason   = 'SAP returned no complete material document key'
                  messages = result-messages.
    ENDIF.
  ENDMETHOD.

  METHOD invoke.
    DATA(bapi_items) = items.
    DATA returned_header TYPE bapi2017_gm_head_ret.
    CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
      EXPORTING
        goodsmvt_header  = header
        goodsmvt_code    = code
        testrun          = test_run
      IMPORTING
        goodsmvt_headret = returned_header
      TABLES
        goodsmvt_item    = bapi_items
        return           = result-messages.
    result-material_document = returned_header-mat_doc.
    result-document_year = returned_header-doc_year.
  ENDMETHOD.
ENDCLASS.
