CLASS ltcl_alloc_checksum DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_checksum.

    METHODS setup.

    METHODS result
      IMPORTING
        iv_id         TYPE zcl_stock_allocator=>ty_result-requirement_id
        iv_allocated  TYPE menge_d
        iv_shortage   TYPE menge_d
      RETURNING
        VALUE(rs_row) TYPE zcl_stock_allocator=>ty_result.

    METHODS empty_is_zero    FOR TESTING.
    METHODS stable_for_same  FOR TESTING.
    METHODS changes_with_qty FOR TESTING.
    METHODS changes_with_id  FOR TESTING.
    METHODS changes_with_order FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_checksum IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_checksum( ).
  ENDMETHOD.

  METHOD result.
    rs_row-requirement_id = iv_id.
    rs_row-allocated_qty = iv_allocated.
    rs_row-shortage_qty = iv_shortage.
  ENDMETHOD.

  METHOD empty_is_zero.
    DATA lt_result TYPE zcl_stock_allocator=>ty_result_tt.

    cl_abap_unit_assert=>assert_equals( act = mo_cut->of_result( lt_result )
                                        exp = 0 ).
  ENDMETHOD.

  METHOD stable_for_same.
    DATA lt_result TYPE zcl_stock_allocator=>ty_result_tt.

    APPEND result( iv_id = 'REQ-1' iv_allocated = '5' iv_shortage = '1' )
      TO lt_result.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->of_result( lt_result )
      exp = mo_cut->of_result( lt_result ) ).
  ENDMETHOD.

  METHOD changes_with_qty.
    DATA lt_low  TYPE zcl_stock_allocator=>ty_result_tt.
    DATA lt_high TYPE zcl_stock_allocator=>ty_result_tt.

    APPEND result( iv_id = 'REQ-1' iv_allocated = '5' iv_shortage = '0' )
      TO lt_low.
    APPEND result( iv_id = 'REQ-1' iv_allocated = '9' iv_shortage = '0' )
      TO lt_high.

    cl_abap_unit_assert=>assert_differs( act = mo_cut->of_result( lt_low )
                                         exp = mo_cut->of_result( lt_high ) ).
  ENDMETHOD.

  METHOD changes_with_id.
    DATA lt_a TYPE zcl_stock_allocator=>ty_result_tt.
    DATA lt_b TYPE zcl_stock_allocator=>ty_result_tt.

    APPEND result( iv_id = 'REQ-1' iv_allocated = '5' iv_shortage = '0' )
      TO lt_a.
    APPEND result( iv_id = 'REQ-XYZ' iv_allocated = '5' iv_shortage = '0' )
      TO lt_b.

    cl_abap_unit_assert=>assert_differs( act = mo_cut->of_result( lt_a )
                                         exp = mo_cut->of_result( lt_b ) ).
  ENDMETHOD.

  METHOD changes_with_order.
    DATA lt_one TYPE zcl_stock_allocator=>ty_result_tt.
    DATA lt_two TYPE zcl_stock_allocator=>ty_result_tt.

    APPEND result( iv_id = 'REQ-1' iv_allocated = '5' iv_shortage = '0' )
      TO lt_one.
    APPEND result( iv_id = 'REQ-22' iv_allocated = '7' iv_shortage = '0' )
      TO lt_one.
    APPEND result( iv_id = 'REQ-22' iv_allocated = '7' iv_shortage = '0' )
      TO lt_two.
    APPEND result( iv_id = 'REQ-1' iv_allocated = '5' iv_shortage = '0' )
      TO lt_two.

    cl_abap_unit_assert=>assert_differs( act = mo_cut->of_result( lt_one )
                                         exp = mo_cut->of_result( lt_two ) ).
  ENDMETHOD.

ENDCLASS.
