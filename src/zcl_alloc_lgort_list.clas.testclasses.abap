CLASS ltcl_alloc_lgort_list DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_lgort_list.

    METHODS setup.

    METHODS alloc
      IMPORTING
        iv_lgort      TYPE lgort_d
      RETURNING
        VALUE(rs_row) TYPE zcl_stock_allocator=>ty_allocation.

    METHODS result_with
      IMPORTING
        iv_lgort_1    TYPE lgort_d
        iv_lgort_2    TYPE lgort_d
      RETURNING
        VALUE(rs_row) TYPE zcl_stock_allocator=>ty_result.

    METHODS empty_list    FOR TESTING.
    METHODS single_bin    FOR TESTING.
    METHODS removes_dups  FOR TESTING.
    METHODS sorted_output FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_lgort_list IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_lgort_list( ).
  ENDMETHOD.

  METHOD alloc.
    rs_row-lgort = iv_lgort.
  ENDMETHOD.

  METHOD result_with.
    APPEND alloc( iv_lgort_1 ) TO rs_row-allocations.
    APPEND alloc( iv_lgort_2 ) TO rs_row-allocations.
  ENDMETHOD.

  METHOD empty_list.
    DATA lt_result TYPE zcl_stock_allocator=>ty_result_tt.

    cl_abap_unit_assert=>assert_initial( act = mo_cut->build( lt_result ) ).
  ENDMETHOD.

  METHOD single_bin.
    DATA lt_result TYPE zcl_stock_allocator=>ty_result_tt.

    APPEND result_with( iv_lgort_1 = '0001' iv_lgort_2 = '0001' )
      TO lt_result.

    DATA(lt_lgort) = mo_cut->build( lt_result ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lgort ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lgort[ 1 ] exp = '0001' ).
  ENDMETHOD.

  METHOD removes_dups.
    DATA lt_result TYPE zcl_stock_allocator=>ty_result_tt.

    APPEND result_with( iv_lgort_1 = '0001' iv_lgort_2 = '0002' )
      TO lt_result.
    APPEND result_with( iv_lgort_1 = '0001' iv_lgort_2 = '0002' )
      TO lt_result.

    DATA(lt_lgort) = mo_cut->build( lt_result ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lgort ) exp = 2 ).
  ENDMETHOD.

  METHOD sorted_output.
    DATA lt_result TYPE zcl_stock_allocator=>ty_result_tt.

    APPEND result_with( iv_lgort_1 = '0002' iv_lgort_2 = '0001' )
      TO lt_result.

    DATA(lt_lgort) = mo_cut->build( lt_result ).

    cl_abap_unit_assert=>assert_equals( act = lt_lgort[ 1 ] exp = '0001' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lgort[ 2 ] exp = '0002' ).
  ENDMETHOD.

ENDCLASS.
