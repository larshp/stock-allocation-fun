CLASS ltcl_unit_conversion_sap DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS rejects_unauthorized_read FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS converts_material_unit FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS normalizes_lowercase_units FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_unknown_conversion FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_invalid_output FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_negative_output FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_nonzero_zero_output FOR TESTING
      RAISING zcx_stock_allocation.
ENDCLASS.

CLASS lcl_fail_unit_auth DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_unit_conversion_authority.
ENDCLASS.

CLASS lcl_fail_unit_auth IMPLEMENTATION.
  METHOD zif_unit_conversion_authority~check.
    DATA lo_error TYPE REF TO zcx_stock_allocation.
    CREATE OBJECT lo_error.
    lo_error->message = 'Unit conversion authority test failure'.
    RAISE EXCEPTION lo_error.
  ENDMETHOD.
ENDCLASS.

CLASS ltcl_unit_conversion_sap IMPLEMENTATION.
  METHOD rejects_unauthorized_read.
    DATA lo_authority TYPE REF TO zif_unit_conversion_authority.
    DATA lo_cut TYPE REF TO zif_unit_conversion.
    DATA lv_raised TYPE abap_bool.
    DATA lv_message TYPE c LENGTH 220.

    CREATE OBJECT lo_authority TYPE lcl_fail_unit_auth.
    CREATE OBJECT lo_cut TYPE zcl_unit_conversion_sap
      EXPORTING
        io_authority = lo_authority.
    TRY.
        lo_cut->convert(
          iv_material  = 'MATERIAL-BOX'
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
      exp = 'Unit conversion authority test failure' ).
  ENDMETHOD.

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

  METHOD normalizes_lowercase_units.
    DATA lo_cut TYPE REF TO zif_unit_conversion.
    DATA lv_quantity TYPE zif_stock_allocation=>ty_quantity.

    CREATE OBJECT lo_cut TYPE zcl_unit_conversion_sap.
    lv_quantity = lo_cut->convert(
      iv_material  = 'MATERIAL-BOX'
      iv_quantity  = '2'
      iv_unit_from = 'box'
      iv_unit_to   = 'ea' ).

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
