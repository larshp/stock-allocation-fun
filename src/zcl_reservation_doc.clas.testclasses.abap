CLASS ltcl_reservation_doc DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_environment TYPE REF TO if_osql_test_environment.
    DATA mo_cut         TYPE REF TO zcl_reservation_doc.

    METHODS setup.
    METHODS teardown.

    METHODS result
      IMPORTING
        it_result        TYPE zcl_stock_allocator=>ty_result_tt
        iv_id            TYPE zcl_stock_allocator=>ty_result-requirement_id
        iv_qty           TYPE menge_d
        iv_lgort         TYPE lgort_d DEFAULT '0001'
        iv_matnr         TYPE matnr DEFAULT ''
      RETURNING
        VALUE(rt_result) TYPE zcl_stock_allocator=>ty_result_tt.

    METHODS create_and_summarize  FOR TESTING.
    METHODS items_only_its_doc    FOR TESTING.
    METHODS summarize_materials   FOR TESTING.
    METHODS release_removes_items FOR TESTING.
    METHODS empty_summary         FOR TESTING.
ENDCLASS.


CLASS ltcl_reservation_doc IMPLEMENTATION.

  METHOD setup.
    mo_environment = cl_osql_test_environment=>create(
      i_dependency_list = VALUE #( ( 'ZSTOCKRESV' ) ) ).
    mo_cut = NEW zcl_reservation_doc( ).
  ENDMETHOD.

  METHOD teardown.
    mo_environment->destroy( ).
  ENDMETHOD.

  METHOD result.
    DATA ls_result TYPE zcl_stock_allocator=>ty_result.
    DATA ls_alloc  TYPE zcl_stock_allocator=>ty_allocation.

    rt_result = it_result.

    ls_result-requirement_id = iv_id.
    ls_result-allocated_qty = iv_qty.

    ls_alloc-lgort = iv_lgort.
    ls_alloc-quantity = iv_qty.
    ls_alloc-matnr = iv_matnr.
    APPEND ls_alloc TO ls_result-allocations.

    APPEND ls_result TO rt_result.
  ENDMETHOD.

  METHOD create_and_summarize.
    DATA lt_result TYPE zcl_stock_allocator=>ty_result_tt.

    lt_result = result( it_result = lt_result iv_id = 'REQ-1' iv_qty = '4' iv_lgort = '0001' ).
    lt_result = result( it_result = lt_result iv_id = 'REQ-1' iv_qty = '2' iv_lgort = '0002' ).

    DATA(rv_written) = mo_cut->create( iv_doc_id = 'DOC-1'
                                       iv_matnr  = 'MAT-1'
                                       iv_werks  = '1000'
                                       it_result = lt_result ).

    cl_abap_unit_assert=>assert_equals( act = rv_written
                                        exp = 2 ).

    DATA(ls_summary) = mo_cut->summarize( 'DOC-1' ).

    cl_abap_unit_assert=>assert_equals( act = ls_summary-doc_id
                                        exp = 'DOC-1' ).
    cl_abap_unit_assert=>assert_equals( act = ls_summary-positions
                                        exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = ls_summary-quantity
                                        exp = '6' ).
  ENDMETHOD.

  METHOD items_only_its_doc.
    DATA lt_result TYPE zcl_stock_allocator=>ty_result_tt.

    lt_result = result( it_result = lt_result iv_id = 'REQ-1' iv_qty = '4' ).
    mo_cut->create( iv_doc_id = 'DOC-1' iv_matnr = 'MAT-1'
                    iv_werks = '1000' it_result = lt_result ).

    lt_result = result( it_result = lt_result iv_id = 'REQ-2' iv_qty = '5' ).
    mo_cut->create( iv_doc_id = 'DOC-2' iv_matnr = 'MAT-2'
                    iv_werks = '1000' it_result = lt_result ).

    DATA(lt_items) = mo_cut->items( 'DOC-1' ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_items )
                                        exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_items[ 1 ]-req_id
                                        exp = 'REQ-1' ).
  ENDMETHOD.

  METHOD summarize_materials.
    DATA lt_result TYPE zcl_stock_allocator=>ty_result_tt.

    lt_result = result( it_result = lt_result iv_id = 'REQ-1' iv_qty = '4' iv_matnr = 'MAT-1' ).
    lt_result = result( it_result = lt_result iv_id = 'REQ-2' iv_qty = '5' iv_matnr = 'MAT-2' ).

    mo_cut->create( iv_doc_id = 'DOC-1' iv_matnr = 'MAT-1'
                    iv_werks = '1000' it_result = lt_result ).

    DATA(ls_summary) = mo_cut->summarize( 'DOC-1' ).

    cl_abap_unit_assert=>assert_equals( act = ls_summary-materials
                                        exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = ls_summary-quantity
                                        exp = '9' ).
  ENDMETHOD.

  METHOD release_removes_items.
    DATA lt_result TYPE zcl_stock_allocator=>ty_result_tt.

    lt_result = result( it_result = lt_result iv_id = 'REQ-1' iv_qty = '4' ).
    mo_cut->create( iv_doc_id = 'DOC-1' iv_matnr = 'MAT-1'
                    iv_werks = '1000' it_result = lt_result ).

    mo_cut->release( 'DOC-1' ).

    cl_abap_unit_assert=>assert_initial( act = mo_cut->items( 'DOC-1' ) ).
  ENDMETHOD.

  METHOD empty_summary.
    DATA(ls_summary) = mo_cut->summarize( 'DOC-X' ).

    cl_abap_unit_assert=>assert_equals( act = ls_summary-doc_id
                                        exp = 'DOC-X' ).
    cl_abap_unit_assert=>assert_equals( act = ls_summary-positions
                                        exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_summary-quantity
                                        exp = '0' ).
  ENDMETHOD.

ENDCLASS.
