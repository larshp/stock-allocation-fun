CLASS ltcl_alloc_export_alloc_xml DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_export_alloc_xml.

    METHODS setup.

    METHODS result_with
      IMPORTING
        iv_id         TYPE zcl_stock_allocator=>ty_result-requirement_id
        iv_matnr      TYPE matnr
        iv_quantity   TYPE menge_d
      RETURNING
        VALUE(rs_row) TYPE zcl_stock_allocator=>ty_result.

    METHODS empty_result FOR TESTING.
    METHODS one_allocation FOR TESTING.
    METHODS skips_zero   FOR TESTING.
    METHODS escapes_id   FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_export_alloc_xml IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_export_alloc_xml( ).
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

    DATA(lt_lines) = mo_cut->build( lt_result ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 3 ]
                                        exp = '</allocations>' ).
  ENDMETHOD.

  METHOD one_allocation.
    DATA lt_result TYPE zcl_stock_allocator=>ty_result_tt.

    APPEND result_with( iv_id = 'REQ-1' iv_matnr = 'MAT-1'
                        iv_quantity = '5' ) TO lt_result.

    DATA(lt_lines) = mo_cut->build( lt_result ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 9 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 3 ]
                                        exp = '  <allocation requirement_id="REQ-1">' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 4 ]
                                        exp = '    <matnr>MAT-1</matnr>' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 7 ]
                                        exp = '    <quantity>5.000</quantity>' ).
  ENDMETHOD.

  METHOD skips_zero.
    DATA lt_result TYPE zcl_stock_allocator=>ty_result_tt.

    APPEND result_with( iv_id = 'REQ-1' iv_matnr = 'MAT-1'
                        iv_quantity = '0' ) TO lt_result.

    DATA(lt_lines) = mo_cut->build( lt_result ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 5 ).
  ENDMETHOD.

  METHOD escapes_id.
    DATA lt_result TYPE zcl_stock_allocator=>ty_result_tt.

    APPEND result_with( iv_id = 'R&1' iv_matnr = 'MAT-1'
                        iv_quantity = '5' ) TO lt_result.

    DATA(lt_lines) = mo_cut->build( lt_result ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_lines[ 3 ]
      exp = '  <allocation requirement_id="R&amp;1">' ).
  ENDMETHOD.

ENDCLASS.
