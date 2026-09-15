CLASS ltcl_alloc_snapshot DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_snapshot.

    METHODS setup.

    METHODS result
      IMPORTING
        iv_id         TYPE zcl_stock_allocator=>ty_result-requirement_id
        iv_allocated  TYPE menge_d
      RETURNING
        VALUE(rs_row) TYPE zcl_stock_allocator=>ty_result.

    METHODS input
      IMPORTING
        it_before     TYPE zcl_stock_allocator=>ty_result_tt
        it_after      TYPE zcl_stock_allocator=>ty_result_tt
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_snapshot=>ty_input.

    METHODS no_change_empty FOR TESTING.
    METHODS increase        FOR TESTING.
    METHODS decrease        FOR TESTING.
    METHODS new_requirement FOR TESTING.
    METHODS removed_requirement FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_snapshot IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_snapshot( ).
  ENDMETHOD.

  METHOD result.
    rs_row-requirement_id = iv_id.
    rs_row-allocated_qty = iv_allocated.
  ENDMETHOD.

  METHOD input.
    rs_row-before = mo_cut->take( it_before ).
    rs_row-after = it_after.
  ENDMETHOD.

  METHOD no_change_empty.
    DATA lt_result TYPE zcl_stock_allocator=>ty_result_tt.

    APPEND result( iv_id = 'REQ-1' iv_allocated = '5' ) TO lt_result.

    cl_abap_unit_assert=>assert_initial(
      act = mo_cut->compare( input( it_before = lt_result
                                    it_after  = lt_result ) ) ).
  ENDMETHOD.

  METHOD increase.
    DATA lt_before TYPE zcl_stock_allocator=>ty_result_tt.
    DATA lt_after  TYPE zcl_stock_allocator=>ty_result_tt.

    APPEND result( iv_id = 'REQ-1' iv_allocated = '5' ) TO lt_before.
    APPEND result( iv_id = 'REQ-1' iv_allocated = '8' ) TO lt_after.

    DATA(lt_lines) = mo_cut->compare( input( it_before = lt_before
                                             it_after  = lt_after ) ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-before_qty
                                        exp = '5' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-after_qty
                                        exp = '8' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-delta_qty
                                        exp = '3' ).
  ENDMETHOD.

  METHOD decrease.
    DATA lt_before TYPE zcl_stock_allocator=>ty_result_tt.
    DATA lt_after  TYPE zcl_stock_allocator=>ty_result_tt.

    APPEND result( iv_id = 'REQ-1' iv_allocated = '8' ) TO lt_before.
    APPEND result( iv_id = 'REQ-1' iv_allocated = '5' ) TO lt_after.

    DATA(lt_lines) = mo_cut->compare( input( it_before = lt_before
                                             it_after  = lt_after ) ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-delta_qty
                                        exp = '-3' ).
  ENDMETHOD.

  METHOD new_requirement.
    DATA lt_before TYPE zcl_stock_allocator=>ty_result_tt.
    DATA lt_after  TYPE zcl_stock_allocator=>ty_result_tt.

    APPEND result( iv_id = 'REQ-1' iv_allocated = '5' ) TO lt_after.

    DATA(lt_lines) = mo_cut->compare( input( it_before = lt_before
                                             it_after  = lt_after ) ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-before_qty
                                        exp = '0' ).
  ENDMETHOD.

  METHOD removed_requirement.
    DATA lt_before TYPE zcl_stock_allocator=>ty_result_tt.
    DATA lt_after  TYPE zcl_stock_allocator=>ty_result_tt.

    APPEND result( iv_id = 'REQ-1' iv_allocated = '5' ) TO lt_before.

    DATA(lt_lines) = mo_cut->compare( input( it_before = lt_before
                                             it_after  = lt_after ) ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-after_qty
                                        exp = '0' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-delta_qty
                                        exp = '-5' ).
  ENDMETHOD.

ENDCLASS.
