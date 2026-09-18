CLASS ltcl_alloc_inventory_value DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_inventory_value.

    METHODS setup.

    METHODS input
      IMPORTING
        iv_quantity   TYPE menge_d
        iv_price      TYPE menge_d
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_inventory_value=>ty_input.

    METHODS multiplies       FOR TESTING.
    METHODS fractional_price FOR TESTING.
    METHODS zero_quantity    FOR TESTING.
    METHODS zero_price       FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_inventory_value IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_inventory_value( ).
  ENDMETHOD.

  METHOD input.
    rs_row-quantity = iv_quantity.
    rs_row-price = iv_price.
  ENDMETHOD.

  METHOD multiplies.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->calculate( input( iv_quantity = '10'
                                      iv_price    = '2.5' ) )
      exp = '25' ).
  ENDMETHOD.

  METHOD fractional_price.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->calculate( input( iv_quantity = '3'
                                      iv_price    = '1.5' ) )
      exp = '4.5' ).
  ENDMETHOD.

  METHOD zero_quantity.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->calculate( input( iv_quantity = '0'
                                      iv_price    = '2.5' ) )
      exp = '0' ).
  ENDMETHOD.

  METHOD zero_price.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->calculate( input( iv_quantity = '10'
                                      iv_price    = '0' ) )
      exp = '0' ).
  ENDMETHOD.

ENDCLASS.
