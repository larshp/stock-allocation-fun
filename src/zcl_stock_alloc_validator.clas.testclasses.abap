CLASS ltcl_stock_alloc_validator DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.
  PRIVATE SECTION.
    METHODS rejects_incomplete_demand FOR TESTING.
    METHODS allows_ignored_nonpositive FOR TESTING RAISING zcx_stock_allocation.
ENDCLASS.

CLASS ltcl_stock_alloc_validator IMPLEMENTATION.
  METHOD rejects_incomplete_demand.
    TRY.
        zcl_stock_alloc_validator=>validate_demands( VALUE #(
          ( sales_order = '1'
            sales_item = '000010'
            schedule_line = '0000'
            delivery_date = '20250101'
            requested_qty = '1' ) ) ).
        cl_abap_unit_assert=>fail( 'Incomplete positive demand must fail' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        cl_abap_unit_assert=>assert_not_initial( lo_error->get_text( ) ).
    ENDTRY.
  ENDMETHOD.

  METHOD allows_ignored_nonpositive.
    zcl_stock_alloc_validator=>validate_demands( VALUE #(
      ( sales_order = ''
        sales_item = '000000'
        schedule_line = '0000'
        delivery_date = '00000000'
        requested_qty = '0' ) ) ).
  ENDMETHOD.
ENDCLASS.
