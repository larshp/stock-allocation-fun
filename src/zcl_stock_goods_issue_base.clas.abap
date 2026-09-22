CLASS zcl_stock_goods_issue_base DEFINITION PUBLIC ABSTRACT CREATE PUBLIC.
  PROTECTED SECTION.
    TYPES ty_items TYPE STANDARD TABLE OF bapi2017_gm_item_create WITH DEFAULT KEY.
    METHODS post FINAL
      IMPORTING header        TYPE bapi2017_gm_head_01
                code          TYPE bapi2017_gm_code
                items         TYPE ty_items
                test_run      TYPE abap_bool
      RETURNING VALUE(result) TYPE zif_stock_goods_issue=>ty_result
      RAISING zcx_stock_alloc.
    METHODS invoke
      IMPORTING header        TYPE bapi2017_gm_head_01
                code          TYPE bapi2017_gm_code
                items         TYPE ty_items
                test_run      TYPE abap_bool
      RETURNING VALUE(result) TYPE zif_stock_goods_issue=>ty_result.
ENDCLASS.

CLASS zcl_stock_goods_issue_base IMPLEMENTATION.
  METHOD post.
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
