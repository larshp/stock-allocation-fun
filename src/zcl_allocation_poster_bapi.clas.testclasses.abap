CLASS ltcl_allocation_poster_bapi DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    TYPES ty_mard_tt TYPE STANDARD TABLE OF mard WITH DEFAULT KEY.

    DATA mo_environment TYPE REF TO if_osql_test_environment.
    DATA mo_cut         TYPE REF TO zif_allocation_poster.

    METHODS setup.
    METHODS teardown.

    METHODS given_stock
      IMPORTING
        iv_lgort TYPE lgort_d
        iv_labst TYPE menge_d DEFAULT 0.

    METHODS allocation_result
      IMPORTING
        iv_lgort         TYPE lgort_d
        iv_qty           TYPE menge_d
      RETURNING
        VALUE(rt_result) TYPE zcl_stock_allocator=>ty_result_tt.

    METHODS current_stock
      IMPORTING
        iv_lgort        TYPE lgort_d
      RETURNING
        VALUE(rv_labst) TYPE menge_d.

    METHODS posts_goods_issue        FOR TESTING.
    METHODS reduces_stock_per_bin    FOR TESTING.
    METHODS empty_result_posts_nothing FOR TESTING.
    METHODS sums_multiple_requirements FOR TESTING.
ENDCLASS.


CLASS ltcl_allocation_poster_bapi IMPLEMENTATION.

  METHOD setup.
    mo_environment = cl_osql_test_environment=>create(
      i_dependency_list = VALUE #( ( 'MARD' ) ) ).
    mo_cut = NEW zcl_allocation_poster_bapi( ).
  ENDMETHOD.

  METHOD teardown.
    mo_environment->destroy( ).
  ENDMETHOD.

  METHOD given_stock.
    DATA ls_mard TYPE mard.

    ls_mard-mandt = sy-mandt.
    ls_mard-matnr = 'MAT-1'.
    ls_mard-werks = '1000'.
    ls_mard-lgort = iv_lgort.
    ls_mard-labst = iv_labst.

    mo_environment->insert_test_data( VALUE ty_mard_tt( ( ls_mard ) ) ).
  ENDMETHOD.

  METHOD allocation_result.
    DATA ls_result     TYPE zcl_stock_allocator=>ty_result.
    DATA ls_allocation TYPE zcl_stock_allocator=>ty_allocation.

    ls_result-requirement_id = 'REQ-1'.
    ls_result-requested_qty  = iv_qty.
    ls_result-allocated_qty  = iv_qty.

    ls_allocation-requirement_id = 'REQ-1'.
    ls_allocation-lgort          = iv_lgort.
    ls_allocation-quantity       = iv_qty.
    APPEND ls_allocation TO ls_result-allocations.

    APPEND ls_result TO rt_result.
  ENDMETHOD.

  METHOD current_stock.
    SELECT SINGLE labst FROM mard INTO @rv_labst
      WHERE matnr = 'MAT-1'
        AND werks = '1000'
        AND lgort = @iv_lgort.
  ENDMETHOD.

  METHOD posts_goods_issue.
    given_stock( iv_lgort = '0001' iv_labst = '10' ).

    DATA(ls_posting) = mo_cut->post(
      it_result    = allocation_result( iv_lgort = '0001' iv_qty = '4' )
      iv_matnr     = 'MAT-1'
      iv_werks     = '1000'
      iv_move_type = '601' ).

    cl_abap_unit_assert=>assert_equals( act = ls_posting-success
                                        exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = ls_posting-document_number
                                        exp = '4900000001' ).
  ENDMETHOD.

  METHOD reduces_stock_per_bin.
    given_stock( iv_lgort = '0001' iv_labst = '10' ).
    given_stock( iv_lgort = '0002' iv_labst = '10' ).

    DATA(ls_posting) = mo_cut->post(
      it_result    = allocation_result( iv_lgort = '0001' iv_qty = '4' )
      iv_matnr     = 'MAT-1'
      iv_werks     = '1000'
      iv_move_type = '601' ).

    cl_abap_unit_assert=>assert_equals( act = ls_posting-success
                                        exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = current_stock( '0001' )
                                        exp = '6' ).
    cl_abap_unit_assert=>assert_equals( act = current_stock( '0002' )
                                        exp = '10' ).
  ENDMETHOD.

  METHOD empty_result_posts_nothing.
    given_stock( iv_lgort = '0001' iv_labst = '10' ).

    DATA lt_empty TYPE zcl_stock_allocator=>ty_result_tt.

    DATA(ls_posting) = mo_cut->post( it_result    = lt_empty
                                     iv_matnr     = 'MAT-1'
                                     iv_werks     = '1000'
                                     iv_move_type = '601' ).

    cl_abap_unit_assert=>assert_equals( act = ls_posting-success
                                        exp = abap_false ).
    cl_abap_unit_assert=>assert_initial( act = ls_posting-document_number ).
    cl_abap_unit_assert=>assert_equals( act = current_stock( '0001' )
                                        exp = '10' ).
  ENDMETHOD.

  METHOD sums_multiple_requirements.
    given_stock( iv_lgort = '0001' iv_labst = '10' ).

    DATA lt_result TYPE zcl_stock_allocator=>ty_result_tt.
    DATA ls_result TYPE zcl_stock_allocator=>ty_result.
    DATA ls_alloc  TYPE zcl_stock_allocator=>ty_allocation.

    ls_result-requirement_id = 'REQ-1'.
    ls_alloc-lgort           = '0001'.
    ls_alloc-quantity        = '3'.
    APPEND ls_alloc TO ls_result-allocations.
    APPEND ls_result TO lt_result.

    CLEAR ls_result.
    ls_result-requirement_id = 'REQ-2'.
    ls_alloc-lgort           = '0001'.
    ls_alloc-quantity        = '2'.
    APPEND ls_alloc TO ls_result-allocations.
    APPEND ls_result TO lt_result.

    DATA(ls_posting) = mo_cut->post( it_result    = lt_result
                                     iv_matnr     = 'MAT-1'
                                     iv_werks     = '1000'
                                     iv_move_type = '601' ).

    cl_abap_unit_assert=>assert_equals( act = ls_posting-success
                                        exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = current_stock( '0001' )
                                        exp = '5' ).
  ENDMETHOD.

ENDCLASS.
