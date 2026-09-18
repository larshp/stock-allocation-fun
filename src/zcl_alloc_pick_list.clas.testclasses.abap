CLASS ltcl_alloc_pick_list DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_pick_list.

    METHODS setup.

    METHODS line
      IMPORTING
        iv_id         TYPE zcl_stock_allocator=>ty_result-requirement_id
        iv_lgort      TYPE lgort_d
        iv_charg      TYPE c
        iv_quantity   TYPE menge_d
      RETURNING
        VALUE(rs_row) TYPE zcl_stock_allocator=>ty_result.

    METHODS empty_result    FOR TESTING.
    METHODS one_position    FOR TESTING.
    METHODS skips_zero_qty  FOR TESTING.
    METHODS flattens_result FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_pick_list IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_pick_list( ).
  ENDMETHOD.

  METHOD line.
    DATA ls_alloc TYPE zcl_stock_allocator=>ty_allocation.

    rs_row-requirement_id = iv_id.
    ls_alloc-lgort = iv_lgort.
    ls_alloc-charg = iv_charg.
    ls_alloc-quantity = iv_quantity.
    APPEND ls_alloc TO rs_row-allocations.
  ENDMETHOD.

  METHOD empty_result.
    DATA lt_result TYPE zcl_stock_allocator=>ty_result_tt.

    cl_abap_unit_assert=>assert_initial( act = mo_cut->build( lt_result ) ).
  ENDMETHOD.

  METHOD one_position.
    DATA lt_result TYPE zcl_stock_allocator=>ty_result_tt.

    APPEND line( iv_id       = 'REQ-1'
                 iv_lgort    = '0001'
                 iv_charg    = 'B1'
                 iv_quantity = '5' ) TO lt_result.

    DATA(lt_lines) = mo_cut->build( lt_result ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-requirement_id
                                        exp = 'REQ-1' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-lgort
                                        exp = '0001' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-charg
                                        exp = 'B1' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-quantity
                                        exp = '5' ).
  ENDMETHOD.

  METHOD skips_zero_qty.
    DATA lt_result TYPE zcl_stock_allocator=>ty_result_tt.

    APPEND line( iv_id       = 'REQ-1'
                 iv_lgort    = '0001'
                 iv_charg    = 'B1'
                 iv_quantity = '0' ) TO lt_result.

    cl_abap_unit_assert=>assert_initial( act = mo_cut->build( lt_result ) ).
  ENDMETHOD.

  METHOD flattens_result.
    DATA lt_result TYPE zcl_stock_allocator=>ty_result_tt.
    DATA ls_row    TYPE zcl_stock_allocator=>ty_result.
    DATA ls_alloc  TYPE zcl_stock_allocator=>ty_allocation.

    ls_row-requirement_id = 'REQ-1'.
    ls_alloc-lgort = '0001'.
    ls_alloc-charg = 'B1'.
    ls_alloc-quantity = '3'.
    APPEND ls_alloc TO ls_row-allocations.
    ls_alloc-lgort = '0002'.
    ls_alloc-charg = 'B2'.
    ls_alloc-quantity = '4'.
    APPEND ls_alloc TO ls_row-allocations.
    APPEND ls_row TO lt_result.

    DATA(lt_lines) = mo_cut->build( lt_result ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ]-lgort
                                        exp = '0002' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ]-quantity
                                        exp = '4' ).
  ENDMETHOD.

ENDCLASS.
