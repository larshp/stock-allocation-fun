CLASS ltcl_deduct_safety_stock DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CONSTANTS c_matnr TYPE mard-matnr VALUE 'DEDUCT-SAFETY-01'.
    CONSTANTS c_werks TYPE mard-werks VALUE '1000'.

    TYPES ty_marc_tab TYPE STANDARD TABLE OF marc WITH EMPTY KEY.

    DATA mo_cut TYPE REF TO zif_stock_deduction.

    METHODS setup.
    METHODS teardown.

    METHODS given_plant_data
      IMPORTING
        it_marc TYPE ty_marc_tab.

    METHODS held_back
      RETURNING
        VALUE(rv_quantity) TYPE zif_allocation=>ty_quantity.

    METHODS safety_stock_is_held_back FOR TESTING.
    METHODS no_plant_data_holds_nothing FOR TESTING.
    METHODS no_safety_stock_holds_nothing FOR TESTING.
    METHODS other_plant_is_ignored FOR TESTING.

ENDCLASS.


CLASS ltcl_deduct_safety_stock IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_deduct_safety_stock( ).
  ENDMETHOD.

  METHOD teardown.
    DELETE FROM marc WHERE matnr = @c_matnr.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).
  ENDMETHOD.

  METHOD given_plant_data.
    INSERT marc FROM TABLE @it_marc.
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0
      msg = 'plant data fixture could not be inserted' ).
  ENDMETHOD.

  METHOD held_back.
    rv_quantity = mo_cut->quantity(
      iv_matnr = c_matnr
      iv_werks = c_werks ).
  ENDMETHOD.

  METHOD safety_stock_is_held_back.

    given_plant_data( VALUE #(
      ( mandt = sy-mandt matnr = c_matnr werks = c_werks dismm = 'PD' eisbe = '25.5' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = held_back( )
      exp = '25.5' ).

  ENDMETHOD.

  METHOD no_plant_data_holds_nothing.

    cl_abap_unit_assert=>assert_equals(
      act = held_back( )
      exp = 0
      msg = 'a material without plant data must not fail the allocation' ).

  ENDMETHOD.

  METHOD no_safety_stock_holds_nothing.

    given_plant_data( VALUE #(
      ( mandt = sy-mandt matnr = c_matnr werks = c_werks dismm = 'PD' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = held_back( )
      exp = 0 ).

  ENDMETHOD.

  METHOD other_plant_is_ignored.

    given_plant_data( VALUE #(
      ( mandt = sy-mandt matnr = c_matnr werks = '2000' dismm = 'PD' eisbe = '99' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = held_back( )
      exp = 0 ).

  ENDMETHOD.

ENDCLASS.
