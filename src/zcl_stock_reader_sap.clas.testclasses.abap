CLASS ltcl_stock_reader_sap DEFINITION FINAL
  FOR TESTING
  RISK LEVEL HARMLESS
  DURATION SHORT.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_stock_reader_sap.

    METHODS setup.
    METHODS accepts_empty_scope FOR TESTING.
    METHODS rejects_missing_material FOR TESTING.
    METHODS rejects_missing_plant FOR TESTING.
ENDCLASS.

CLASS ltcl_stock_reader_sap IMPLEMENTATION.
  METHOD setup.
    mo_cut = NEW #( ).
  ENDMETHOD.

  METHOD accepts_empty_scope.
    DATA(ls_result) = mo_cut->zif_stock_reader~read_stock( VALUE #( ) ).

    cl_abap_unit_assert=>assert_true( ls_result-is_success ).
    cl_abap_unit_assert=>assert_initial( ls_result-stock ).
  ENDMETHOD.

  METHOD rejects_missing_material.
    DATA(ls_result) = mo_cut->zif_stock_reader~read_stock(
      VALUE #(
        ( request_id       = 'REQUEST-1'
          plant            = '1000'
          storage_location = '0001' ) ) ).

    cl_abap_unit_assert=>assert_false( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Stock request scope is invalid' ).
    cl_abap_unit_assert=>assert_initial( ls_result-stock ).
  ENDMETHOD.

  METHOD rejects_missing_plant.
    DATA(ls_result) = mo_cut->zif_stock_reader~read_stock(
      VALUE #(
        ( request_id       = 'REQUEST-1'
          material         = 'MAT-1'
          storage_location = '0001' ) ) ).

    cl_abap_unit_assert=>assert_false( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Stock request scope is invalid' ).
    cl_abap_unit_assert=>assert_initial( ls_result-stock ).
  ENDMETHOD.
ENDCLASS.
