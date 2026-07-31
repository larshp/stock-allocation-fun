CLASS ltcl_stock_source_sap DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS reads_current_client_stock FOR TESTING.
ENDCLASS.

CLASS ltcl_stock_source_sap IMPLEMENTATION.
  METHOD reads_current_client_stock.
    DATA lo_cut TYPE REF TO zif_stock_source.
    DATA ls_available TYPE zif_stock_allocation=>ty_available.

    CREATE OBJECT lo_cut TYPE zcl_stock_source_sap.
    ls_available = lo_cut->get_available(
      iv_material         = 'MATERIAL-STOCK'
      iv_plant            = '1000'
      iv_storage_location = '0001' ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_available-quantity
      exp = '12' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_available-unit
      exp = 'EA' ).
    cl_abap_unit_assert=>assert_true( ls_available-material_found ).
    ls_available = lo_cut->get_available(
      iv_material         = 'MATERIAL-BATCH'
      iv_plant            = '1000'
      iv_storage_location = '0001' ).
    cl_abap_unit_assert=>assert_true( ls_available-batch_managed ).

    ls_available = lo_cut->get_available(
      iv_material         = 'MATERIAL-STOCK'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_batch            = 'BATCH-001' ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_available-quantity
      exp = '4' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_available-unit
      exp = 'EA' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_available-batch_expiration_date
      exp = '20261231' ).
    cl_abap_unit_assert=>assert_true( ls_available-batch_found ).

    ls_available = lo_cut->get_available(
      iv_material         = 'MATERIAL-MISSING'
      iv_plant            = '1000'
      iv_storage_location = '0001' ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_available-quantity
      exp = '0' ).
    cl_abap_unit_assert=>assert_false( ls_available-material_found ).
  ENDMETHOD.
ENDCLASS.
