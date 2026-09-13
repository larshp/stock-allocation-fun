CLASS ltcl_alloc_export_alloc_json DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_export_alloc_json.

    METHODS setup.

    METHODS result_with
      IMPORTING
        iv_id         TYPE zcl_stock_allocator=>ty_result-requirement_id
        iv_matnr      TYPE matnr
        iv_quantity   TYPE menge_d
      RETURNING
        VALUE(rs_row) TYPE zcl_stock_allocator=>ty_result.

    METHODS empty_result FOR TESTING.
    METHODS one_entry    FOR TESTING.
    METHODS skips_zero   FOR TESTING.
    METHODS two_entries  FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_export_alloc_json IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_export_alloc_json( ).
  ENDMETHOD.

  METHOD result_with.
    DATA ls_alloc TYPE zcl_stock_allocator=>ty_allocation.

    rs_row-requirement_id = iv_id.
    ls_alloc-matnr = iv_matnr.
    ls_alloc-lgort = '0001'.
    ls_alloc-charg = 'B1'.
    ls_alloc-quantity = iv_quantity.
    APPEND ls_alloc TO rs_row-allocations.
  ENDMETHOD.

  METHOD empty_result.
    DATA lt_result TYPE zcl_stock_allocator=>ty_result_tt.

    cl_abap_unit_assert=>assert_equals( act = mo_cut->build( lt_result )
                                        exp = '[]' ).
  ENDMETHOD.

  METHOD one_entry.
    DATA lt_result TYPE zcl_stock_allocator=>ty_result_tt.

    APPEND result_with( iv_id = 'REQ-1' iv_matnr = 'MAT-1'
                        iv_quantity = '5' ) TO lt_result.

    DATA(lv_json) = mo_cut->build( lt_result ).

    cl_abap_unit_assert=>assert_differs(
      act = find( val = lv_json sub = '"requirement_id":"REQ-1"' )
      exp = -1 ).
    cl_abap_unit_assert=>assert_differs(
      act = find( val = lv_json sub = '"quantity":5.000' )
      exp = -1 ).
  ENDMETHOD.

  METHOD skips_zero.
    DATA lt_result TYPE zcl_stock_allocator=>ty_result_tt.

    APPEND result_with( iv_id = 'REQ-1' iv_matnr = 'MAT-1'
                        iv_quantity = '0' ) TO lt_result.

    DATA(lv_json) = mo_cut->build( lt_result ).

    cl_abap_unit_assert=>assert_differs(
      act = find( val = lv_json sub = '"allocations":[]' )
      exp = -1 ).
  ENDMETHOD.

  METHOD two_entries.
    DATA lt_result TYPE zcl_stock_allocator=>ty_result_tt.

    APPEND result_with( iv_id = 'REQ-1' iv_matnr = 'MAT-1'
                        iv_quantity = '5' ) TO lt_result.
    APPEND result_with( iv_id = 'REQ-2' iv_matnr = 'MAT-2'
                        iv_quantity = '3' ) TO lt_result.

    DATA(lv_json) = mo_cut->build( lt_result ).

    cl_abap_unit_assert=>assert_differs(
      act = find( val = lv_json sub = '"requirement_id":"REQ-2"' )
      exp = -1 ).
  ENDMETHOD.

ENDCLASS.
