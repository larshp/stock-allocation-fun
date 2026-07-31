CLASS ltcl_unit_conversion_sap DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS converts_material_unit FOR TESTING.
    METHODS rejects_unknown_conversion FOR TESTING.
    METHODS rejects_invalid_output FOR TESTING.
    METHODS rejects_negative_output FOR TESTING.
    METHODS rejects_nonzero_zero_output FOR TESTING.
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
    DATA lv_message TYPE c LENGTH 220.

    CREATE OBJECT lo_cut TYPE zcl_unit_conversion_sap.
    TRY.
        lv_quantity = lo_cut->convert(
          iv_material  = 'MATERIAL-UNKNOWN'
          iv_quantity  = '2'
          iv_unit_from = 'BOX'
          iv_unit_to   = 'EA' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        lv_message = lo_error->message.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Unit conversion failed' ).
  ENDMETHOD.

  METHOD rejects_invalid_output.
    DATA lo_cut TYPE REF TO zif_unit_conversion.
    DATA lv_quantity TYPE zif_stock_allocation=>ty_quantity.
    DATA lv_raised TYPE abap_bool.
    DATA lv_message TYPE c LENGTH 220.

    CREATE OBJECT lo_cut TYPE zcl_unit_conversion_sap.
    TRY.
        lv_quantity = lo_cut->convert(
          iv_material  = 'MATERIAL-ZERO-CONVERSION'
          iv_quantity  = '2'
          iv_unit_from = 'BOX'
          iv_unit_to   = 'EA' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        lv_message = lo_error->message.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Unit conversion produced invalid quantity' ).
  ENDMETHOD.

  METHOD rejects_negative_output.
    DATA lo_cut TYPE REF TO zif_unit_conversion.
    DATA lv_quantity TYPE zif_stock_allocation=>ty_quantity.
    DATA lv_raised TYPE abap_bool.
    DATA lv_message TYPE c LENGTH 220.

    CREATE OBJECT lo_cut TYPE zcl_unit_conversion_sap.
    TRY.
        lv_quantity = lo_cut->convert(
          iv_material  = 'MATERIAL-NEGATIVE-CONVERSION'
          iv_quantity  = '0'
          iv_unit_from = 'BOX'
          iv_unit_to   = 'EA' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        lv_message = lo_error->message.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Unit conversion produced invalid quantity' ).
  ENDMETHOD.

  METHOD rejects_nonzero_zero_output.
    DATA lo_cut TYPE REF TO zif_unit_conversion.
    DATA lv_quantity TYPE zif_stock_allocation=>ty_quantity.
    DATA lv_raised TYPE abap_bool.
    DATA lv_message TYPE c LENGTH 220.

    CREATE OBJECT lo_cut TYPE zcl_unit_conversion_sap.
    TRY.
        lv_quantity = lo_cut->convert(
          iv_material  = 'MATERIAL-POSITIVE-ZERO-CONVERSION'
          iv_quantity  = '0'
          iv_unit_from = 'BOX'
          iv_unit_to   = 'EA' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        lv_message = lo_error->message.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Unit conversion produced invalid quantity' ).
  ENDMETHOD.
ENDCLASS.
