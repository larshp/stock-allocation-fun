CLASS ltcl_unit_conversion_sap DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS converts_material_unit FOR TESTING.
    METHODS rejects_unknown_conversion FOR TESTING.
ENDCLASS.

CLASS ltcl_unit_conversion_sap IMPLEMENTATION.
  METHOD converts_material_unit.
    DATA lo_cut TYPE REF TO zif_unit_conversion.
    DATA lv_quantity TYPE zif_stock_allocation=>ty_quantity.

    CREATE OBJECT lo_cut TYPE zcl_unit_conversion_sap.
    lv_quantity = lo_cut->convert(
      iv_material  = 'MATERIAL-BOX'
      iv_quantity  = '2'
      iv_unit_from = 'BOX'
      iv_unit_to   = 'EA' ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_quantity
      exp = '20' ).
  ENDMETHOD.

  METHOD rejects_unknown_conversion.
    DATA lo_cut TYPE REF TO zif_unit_conversion.
    DATA lv_quantity TYPE zif_stock_allocation=>ty_quantity.
    DATA lv_raised TYPE abap_bool.

    CREATE OBJECT lo_cut TYPE zcl_unit_conversion_sap.
    TRY.
        lv_quantity = lo_cut->convert(
          iv_material  = 'MATERIAL-UNKNOWN'
          iv_quantity  = '2'
          iv_unit_from = 'BOX'
          iv_unit_to   = 'EA' ).
      CATCH zcx_stock_allocation.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
  ENDMETHOD.
ENDCLASS.
