CLASS ltcl_alloc_over_check DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_over_check.

    METHODS setup.

    METHODS line
      IMPORTING
        iv_id         TYPE zcl_stock_allocator=>ty_result-requirement_id
        iv_requested  TYPE menge_d
        iv_allocated  TYPE menge_d
      RETURNING
        VALUE(rs_row) TYPE zcl_stock_allocator=>ty_result.

    METHODS empty_result     FOR TESTING.
    METHODS none_over        FOR TESTING.
    METHODS one_over         FOR TESTING.
    METHODS equal_not_over   FOR TESTING.
    METHODS reports_quantities FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_over_check IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_over_check( ).
  ENDMETHOD.

  METHOD line.
    rs_row-requirement_id = iv_id.
    rs_row-requested_qty = iv_requested.
    rs_row-allocated_qty = iv_allocated.
  ENDMETHOD.

  METHOD empty_result.
    DATA lt_result TYPE zcl_stock_allocator=>ty_result_tt.

    cl_abap_unit_assert=>assert_initial( act = mo_cut->find( lt_result ) ).
  ENDMETHOD.

  METHOD none_over.
    DATA lt_result TYPE zcl_stock_allocator=>ty_result_tt.

    APPEND line( iv_id        = 'REQ-1'
                 iv_requested = '10'
                 iv_allocated = '6' ) TO lt_result.

    cl_abap_unit_assert=>assert_initial( act = mo_cut->find( lt_result ) ).
  ENDMETHOD.

  METHOD one_over.
    DATA lt_result TYPE zcl_stock_allocator=>ty_result_tt.

    APPEND line( iv_id        = 'REQ-1'
                 iv_requested = '10'
                 iv_allocated = '6' ) TO lt_result.
    APPEND line( iv_id        = 'REQ-2'
                 iv_requested = '5'
                 iv_allocated = '7' ) TO lt_result.

    DATA(lt_overs) = mo_cut->find( lt_result ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_overs ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_overs[ 1 ]-requirement_id
                                        exp = 'REQ-2' ).
  ENDMETHOD.

  METHOD equal_not_over.
    DATA lt_result TYPE zcl_stock_allocator=>ty_result_tt.

    APPEND line( iv_id        = 'REQ-1'
                 iv_requested = '10'
                 iv_allocated = '10' ) TO lt_result.

    cl_abap_unit_assert=>assert_initial( act = mo_cut->find( lt_result ) ).
  ENDMETHOD.

  METHOD reports_quantities.
    DATA lt_result TYPE zcl_stock_allocator=>ty_result_tt.

    APPEND line( iv_id        = 'REQ-1'
                 iv_requested = '5'
                 iv_allocated = '8' ) TO lt_result.

    DATA(lt_overs) = mo_cut->find( lt_result ).

    cl_abap_unit_assert=>assert_equals( act = lt_overs[ 1 ]-requested_qty
                                        exp = '5' ).
    cl_abap_unit_assert=>assert_equals( act = lt_overs[ 1 ]-allocated_qty
                                        exp = '8' ).
  ENDMETHOD.

ENDCLASS.
