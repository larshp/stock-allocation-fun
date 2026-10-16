CLASS ltcl_alloc_interco_arms DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_interco_arms.

    METHODS setup.

    METHODS arms_length_rule FOR TESTING.
    METHODS computes_gap     FOR TESTING.
    METHODS reads_direction  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_interco_arms IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_interco_arms( ).
  ENDMETHOD.

  METHOD arms_length_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_arms_length( iv_transfer_price    = 1040
                                    iv_market_price      = 1000
                                    iv_tolerance_percent = 5 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_arms_length( iv_transfer_price    = 1060
                                    iv_market_price      = 1000
                                    iv_tolerance_percent = 5 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD computes_gap.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->gap( iv_transfer_price = 1040 iv_market_price = 1000 )
      exp = 40 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->gap( iv_transfer_price = 960 iv_market_price = 1000 )
      exp = 40 ).
  ENDMETHOD.

  METHOD reads_direction.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->direction( iv_transfer_price = 1040 iv_market_price = 1000 )
      exp = 'ABOVE' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->direction( iv_transfer_price = 960 iv_market_price = 1000 )
      exp = 'BELOW' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->direction( iv_transfer_price = 1000 iv_market_price = 1000 )
      exp = 'EQUAL' ).
  ENDMETHOD.

ENDCLASS.
