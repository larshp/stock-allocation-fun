CLASS ltcl_stock_source_sap DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.
  PRIVATE SECTION.
    METHODS reads_quantity_and_unit FOR TESTING.
ENDCLASS.

CLASS ltcl_stock_source_sap IMPLEMENTATION.
  METHOD reads_quantity_and_unit.
    DATA(ls_stock) = NEW zcl_stock_source_sap(
      )->zif_stock_source~get_available(
        iv_material = 'ZUT-SOURCE'
        iv_plant = 'UT01'
        iv_storage_location = 'UT01' ).

    cl_abap_unit_assert=>assert_equals( act = ls_stock-quantity exp = '12.500' ).
    cl_abap_unit_assert=>assert_equals( act = ls_stock-unit exp = 'EA' ).
  ENDMETHOD.
ENDCLASS.
