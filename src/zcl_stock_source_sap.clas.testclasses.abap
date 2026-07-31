CLASS ltcl_stock_source_sap DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS reads_current_client_stock FOR TESTING.
ENDCLASS.

CLASS ltcl_stock_source_sap IMPLEMENTATION.
  METHOD reads_current_client_stock.
    DATA lo_cut TYPE REF TO zif_stock_source.
    DATA lv_available TYPE zif_stock_allocation=>ty_quantity.

    CREATE OBJECT lo_cut TYPE zcl_stock_source_sap.
    lv_available = lo_cut->get_available(
      iv_material         = 'MATERIAL-STOCK'
      iv_plant            = '1000'
      iv_storage_location = '0001' ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_available
      exp = '12' ).

    lv_available = lo_cut->get_available(
      iv_material         = 'MATERIAL-MISSING'
      iv_plant            = '1000'
      iv_storage_location = '0001' ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_available
      exp = '0' ).
  ENDMETHOD.
ENDCLASS.
