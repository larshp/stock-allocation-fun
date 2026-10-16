CLASS ltcl_alloc_footprint DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_footprint.

    METHODS setup.

    METHODS input
      IMPORTING
        iv_distance   TYPE i
        iv_quantity   TYPE menge_d
        iv_factor     TYPE menge_d
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_footprint=>ty_input.

    METHODS multiplies    FOR TESTING.
    METHODS zero_distance FOR TESTING.
    METHODS zero_quantity FOR TESTING.
    METHODS zero_factor   FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_footprint IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_footprint( ).
  ENDMETHOD.

  METHOD input.
    rs_row-distance_km = iv_distance.
    rs_row-quantity = iv_quantity.
    rs_row-factor = iv_factor.
  ENDMETHOD.

  METHOD multiplies.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->estimate( input( iv_distance = 100
                                     iv_quantity = '2'
                                     iv_factor   = '0.5' ) )
      exp = '100' ).
  ENDMETHOD.

  METHOD zero_distance.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->estimate( input( iv_distance = 0
                                     iv_quantity = '2'
                                     iv_factor   = '0.5' ) )
      exp = '0' ).
  ENDMETHOD.

  METHOD zero_quantity.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->estimate( input( iv_distance = 100
                                     iv_quantity = '0'
                                     iv_factor   = '0.5' ) )
      exp = '0' ).
  ENDMETHOD.

  METHOD zero_factor.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->estimate( input( iv_distance = 100
                                     iv_quantity = '2'
                                     iv_factor   = '0' ) )
      exp = '0' ).
  ENDMETHOD.

ENDCLASS.
