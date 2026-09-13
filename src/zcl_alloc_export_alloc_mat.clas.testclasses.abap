CLASS ltcl_alloc_export_alloc_mat DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_export_alloc_mat.

    METHODS setup.

    METHODS result_with
      IMPORTING
        iv_matnr      TYPE matnr
        iv_quantity   TYPE menge_d
      RETURNING
        VALUE(rs_row) TYPE zcl_stock_allocator=>ty_result.

    METHODS header_only  FOR TESTING.
    METHODS groups_matnr FOR TESTING.
    METHODS sorts_matnr  FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_export_alloc_mat IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_export_alloc_mat( ).
  ENDMETHOD.

  METHOD result_with.
    DATA ls_alloc TYPE zcl_stock_allocator=>ty_allocation.

    ls_alloc-matnr = iv_matnr.
    ls_alloc-quantity = iv_quantity.
    APPEND ls_alloc TO rs_row-allocations.
  ENDMETHOD.

  METHOD header_only.
    DATA lt_result TYPE zcl_stock_allocator=>ty_result_tt.

    DATA(lt_lines) = mo_cut->build( lt_result ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]
                                        exp = 'MATNR;POSITIONS;QUANTITY' ).
  ENDMETHOD.

  METHOD groups_matnr.
    DATA lt_result TYPE zcl_stock_allocator=>ty_result_tt.

    APPEND result_with( iv_matnr = 'MAT-1' iv_quantity = '4' ) TO lt_result.
    APPEND result_with( iv_matnr = 'MAT-1' iv_quantity = '5' ) TO lt_result.

    DATA(lt_lines) = mo_cut->build( lt_result ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ]
                                        exp = 'MAT-1;2;9.000' ).
  ENDMETHOD.

  METHOD sorts_matnr.
    DATA lt_result TYPE zcl_stock_allocator=>ty_result_tt.

    APPEND result_with( iv_matnr = 'MAT-2' iv_quantity = '1' ) TO lt_result.
    APPEND result_with( iv_matnr = 'MAT-1' iv_quantity = '1' ) TO lt_result.

    DATA(lt_lines) = mo_cut->build( lt_result ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ]
                                        exp = 'MAT-1;1;1.000' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 3 ]
                                        exp = 'MAT-2;1;1.000' ).
  ENDMETHOD.

ENDCLASS.
