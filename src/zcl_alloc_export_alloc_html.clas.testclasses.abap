CLASS ltcl_alloc_export_alloc_html DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_export_alloc_html.

    METHODS setup.

    METHODS result_with
      IMPORTING
        iv_id         TYPE zcl_stock_allocator=>ty_result-requirement_id
        iv_matnr      TYPE matnr
        iv_quantity   TYPE menge_d
      RETURNING
        VALUE(rs_row) TYPE zcl_stock_allocator=>ty_result.

    METHODS header_only FOR TESTING.
    METHODS one_row      FOR TESTING.
    METHODS escapes_cell FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_export_alloc_html IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_export_alloc_html( ).
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

  METHOD header_only.
    DATA lt_result TYPE zcl_stock_allocator=>ty_result_tt.

    DATA(lt_lines) = mo_cut->build( lt_result ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 7 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]
                                        exp = '<table>' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 7 ]
                                        exp = '</table>' ).
  ENDMETHOD.

  METHOD one_row.
    DATA lt_result TYPE zcl_stock_allocator=>ty_result_tt.

    APPEND result_with( iv_id = 'REQ-1' iv_matnr = 'MAT-1'
                        iv_quantity = '5' ) TO lt_result.

    DATA(lt_lines) = mo_cut->build( lt_result ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 8 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_lines[ 6 ]
      exp = '<tr><td>REQ-1</td><td>MAT-1</td><td>0001</td>' &&
            '<td>B1</td><td>5.000</td></tr>' ).
  ENDMETHOD.

  METHOD escapes_cell.
    DATA lt_result TYPE zcl_stock_allocator=>ty_result_tt.

    APPEND result_with( iv_id = 'R&1' iv_matnr = 'MAT-1'
                        iv_quantity = '5' ) TO lt_result.

    DATA(lt_lines) = mo_cut->build( lt_result ).

    cl_abap_unit_assert=>assert_equals(
      act = find( val = lt_lines[ 6 ] sub = 'R&amp;1' )
      exp = 8 ).
  ENDMETHOD.

ENDCLASS.
