CLASS ltcl_alloc_number_format DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_number_format.

    METHODS setup.

    METHODS qty_has_decimals   FOR TESTING.
    METHODS zero_quantity      FOR TESTING.
    METHODS trims_trailing_zeros FOR TESTING.
    METHODS keeps_integer      FOR TESTING.
    METHODS whole_value_trimmed FOR TESTING.
    METHODS empty_text_kept    FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_number_format IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_number_format( ).
  ENDMETHOD.

  METHOD qty_has_decimals.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->format_qty( '5' )
                                        exp = '5.000' ).
  ENDMETHOD.

  METHOD zero_quantity.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->format_qty( '0' )
                                        exp = '0.000' ).
  ENDMETHOD.

  METHOD trims_trailing_zeros.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->trim_zeros( '5.500' )
                                        exp = '5.5' ).
  ENDMETHOD.

  METHOD keeps_integer.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->trim_zeros( '5' )
                                        exp = '5' ).
  ENDMETHOD.

  METHOD whole_value_trimmed.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->trim_zeros( '5.000' )
                                        exp = '5' ).
  ENDMETHOD.

  METHOD empty_text_kept.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->trim_zeros( '' )
                                        exp = '' ).
  ENDMETHOD.

ENDCLASS.
