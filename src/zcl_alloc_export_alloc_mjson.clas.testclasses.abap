CLASS ltcl_alloc_export_alloc_mjson DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_export_alloc_mjson.

    METHODS setup.

    METHODS result_with
      IMPORTING
        iv_matnr      TYPE matnr
        iv_quantity   TYPE menge_d
      RETURNING
        VALUE(rs_row) TYPE zcl_stock_allocator=>ty_result.

    METHODS empty_result FOR TESTING.
    METHODS one_material FOR TESTING.
    METHODS two_materials FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_export_alloc_mjson IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_export_alloc_mjson( ).
  ENDMETHOD.

  METHOD result_with.
    DATA ls_alloc TYPE zcl_stock_allocator=>ty_allocation.

    ls_alloc-matnr = iv_matnr.
    ls_alloc-quantity = iv_quantity.
    APPEND ls_alloc TO rs_row-allocations.
  ENDMETHOD.

  METHOD empty_result.
    DATA lt_result TYPE zcl_stock_allocator=>ty_result_tt.

    cl_abap_unit_assert=>assert_equals( act = mo_cut->build( lt_result )
                                        exp = '[]' ).
  ENDMETHOD.

  METHOD one_material.
    DATA lt_result TYPE zcl_stock_allocator=>ty_result_tt.

    APPEND result_with( iv_matnr = 'MAT-1' iv_quantity = '4' ) TO lt_result.
    APPEND result_with( iv_matnr = 'MAT-1' iv_quantity = '5' ) TO lt_result.

    DATA(lv_json) = mo_cut->build( lt_result ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_json
      exp = '[{"matnr":"MAT-1","positions":2,"quantity":9.000}]' ).
  ENDMETHOD.

  METHOD two_materials.
    DATA lt_result TYPE zcl_stock_allocator=>ty_result_tt.

    APPEND result_with( iv_matnr = 'MAT-2' iv_quantity = '1' ) TO lt_result.
    APPEND result_with( iv_matnr = 'MAT-1' iv_quantity = '2' ) TO lt_result.

    DATA(lv_json) = mo_cut->build( lt_result ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_json
      exp = '[{"matnr":"MAT-1","positions":1,"quantity":2.000},' &&
            '{"matnr":"MAT-2","positions":1,"quantity":1.000}]' ).
  ENDMETHOD.

ENDCLASS.
