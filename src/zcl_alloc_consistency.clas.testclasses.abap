CLASS ltcl_alloc_consistency DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_consistency.

    METHODS setup.

    METHODS line
      IMPORTING
        iv_id         TYPE zcl_stock_allocator=>ty_result-requirement_id
        iv_requested  TYPE menge_d
        iv_allocated  TYPE menge_d
        iv_shortage   TYPE menge_d
      RETURNING
        VALUE(rs_row) TYPE zcl_stock_allocator=>ty_result.

    METHODS consistent_row   FOR TESTING.
    METHODS empty_result     FOR TESTING.
    METHODS over_allocated   FOR TESTING.
    METHODS wrong_shortage   FOR TESTING.
    METHODS negative_allocated FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_consistency IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_consistency( ).
  ENDMETHOD.

  METHOD line.
    rs_row-requirement_id = iv_id.
    rs_row-requested_qty = iv_requested.
    rs_row-allocated_qty = iv_allocated.
    rs_row-shortage_qty = iv_shortage.
  ENDMETHOD.

  METHOD consistent_row.
    DATA lt_result TYPE zcl_stock_allocator=>ty_result_tt.

    APPEND line( iv_id        = 'REQ-1'
                 iv_requested = '10'
                 iv_allocated = '6'
                 iv_shortage  = '4' ) TO lt_result.

    cl_abap_unit_assert=>assert_initial( act = mo_cut->check( lt_result ) ).
  ENDMETHOD.

  METHOD empty_result.
    DATA lt_result TYPE zcl_stock_allocator=>ty_result_tt.

    cl_abap_unit_assert=>assert_initial( act = mo_cut->check( lt_result ) ).
  ENDMETHOD.

  METHOD over_allocated.
    DATA lt_result TYPE zcl_stock_allocator=>ty_result_tt.

    APPEND line( iv_id        = 'REQ-1'
                 iv_requested = '10'
                 iv_allocated = '12'
                 iv_shortage  = '0' ) TO lt_result.

    DATA(lt_issues) = mo_cut->check( lt_result ).

    " the over-allocation is reported, and so is the resulting shortage mismatch
    cl_abap_unit_assert=>assert_equals( act = lines( lt_issues ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_issues[ 1 ]-requirement_id
                                        exp = 'REQ-1' ).
    cl_abap_unit_assert=>assert_equals( act = lt_issues[ 1 ]-message
                                        exp = 'Allocated quantity exceeds requested' ).
  ENDMETHOD.

  METHOD wrong_shortage.
    DATA lt_result TYPE zcl_stock_allocator=>ty_result_tt.

    APPEND line( iv_id        = 'REQ-1'
                 iv_requested = '10'
                 iv_allocated = '6'
                 iv_shortage  = '9' ) TO lt_result.

    DATA(lt_issues) = mo_cut->check( lt_result ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_issues ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_issues[ 1 ]-message
                                        exp = 'Shortage does not match requested minus allocated' ).
  ENDMETHOD.

  METHOD negative_allocated.
    DATA lt_result TYPE zcl_stock_allocator=>ty_result_tt.

    APPEND line( iv_id        = 'REQ-1'
                 iv_requested = '10'
                 iv_allocated = '-1'
                 iv_shortage  = '11' ) TO lt_result.

    DATA(lt_issues) = mo_cut->check( lt_result ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_issues ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_issues[ 1 ]-message
                                        exp = 'Allocated quantity is negative' ).
  ENDMETHOD.

ENDCLASS.
