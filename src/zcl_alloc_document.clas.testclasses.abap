CLASS ltcl_alloc_document DEFINITION FINAL
  FOR TESTING
  RISK LEVEL HARMLESS
  DURATION SHORT.

  PRIVATE SECTION.
    METHODS setup.
    METHODS create_and_read FOR TESTING.
    METHODS status_lifecycle FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_document IMPLEMENTATION.


  METHOD setup.
    zcl_alloc_document=>clear( ).
  ENDMETHOD.


  METHOD create_and_read.
    " create a document from allocations and read it back
    DATA(lt_allocations) = VALUE zcl_stock_allocator=>tt_allocations(
        ( vbeln = '0000000100' posnr = '000010' matnr = 'MAT1'
          werks = '1000' lgort = '0001' qty_req = '5'
          qty_alloc = '5' )
        ( vbeln = '0000000101' posnr = '000010' matnr = 'MAT2'
          werks = '1000' lgort = '0002' qty_req = '3'
          qty_alloc = '2' ) ).

    DATA(lv_docnr) = zcl_alloc_document=>create(
        it_allocations = lt_allocations ).

    cl_abap_unit_assert=>assert_not_initial( lv_docnr ).

    DATA(ls_doc) = zcl_alloc_document=>read( iv_docnr = lv_docnr ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_doc-items )
      msg = 'document holds both allocation rows' ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'O'
      act = ls_doc-status
      msg = 'new document is open' ).
  ENDMETHOD.


  METHOD status_lifecycle.
    " document numbers increase and status changes to posted
    DATA(lt_one) = VALUE zcl_stock_allocator=>tt_allocations(
        ( vbeln = '0000000110' posnr = '000010' matnr = 'MAT9'
          werks = '1000' lgort = '0001' qty_req = '1'
          qty_alloc = '1' ) ).

    DATA(lv_doc1) = zcl_alloc_document=>create(
        it_allocations = lt_one ).
    DATA(lv_doc2) = zcl_alloc_document=>create(
        it_allocations = lt_one ).

    cl_abap_unit_assert=>assert_not_initial( lv_doc1 ).
    cl_abap_unit_assert=>assert_not_initial( lv_doc2 ).
    cl_abap_unit_assert=>assert_differs(
      act = lv_doc1
      exp = lv_doc2 ).

    zcl_alloc_document=>set_posted( iv_docnr = lv_doc1 ).

    DATA(ls_doc) = zcl_alloc_document=>read( iv_docnr = lv_doc1 ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'P'
      act = ls_doc-status
      msg = 'document marked as posted' ).

    " unknown document number returns an initial structure
    DATA(ls_unknown) = zcl_alloc_document=>read( iv_docnr = '9999999999' ).
    cl_abap_unit_assert=>assert_initial( ls_unknown-docnr ).
  ENDMETHOD.


ENDCLASS.
