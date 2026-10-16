CLASS ltcl_alloc_percent DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_percent.

    METHODS setup.

    METHODS ratio_is_floored  FOR TESTING.
    METHODS ratio_zero_total  FOR TESTING.
    METHODS ratio_full        FOR TESTING.
    METHODS apply_is_scaled   FOR TESTING.
    METHODS format_has_symbol FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_percent IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_percent( ).
  ENDMETHOD.

  METHOD ratio_is_floored.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->ratio( iv_part  = '6'
                                                             iv_total = '10' )
                                        exp = 60 ).
  ENDMETHOD.

  METHOD ratio_zero_total.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->ratio( iv_part  = '6'
                                                             iv_total = '0' )
                                        exp = 0 ).
  ENDMETHOD.

  METHOD ratio_full.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->ratio( iv_part  = '1'
                                                             iv_total = '3' )
                                        exp = 33 ).
  ENDMETHOD.

  METHOD apply_is_scaled.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->apply( iv_pct  = 50
                                                             iv_base = '10' )
                                        exp = '5' ).
  ENDMETHOD.

  METHOD format_has_symbol.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->format( 60 )
                                        exp = '60 %' ).
  ENDMETHOD.

ENDCLASS.
