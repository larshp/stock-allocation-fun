CLASS ltcl_alloc_count_variance DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_count_variance.

    METHODS setup.

    METHODS gain_signed    FOR TESTING.
    METHODS loss_signed    FOR TESTING.
    METHODS percent_abs    FOR TESTING.
    METHODS percent_zero   FOR TESTING.
    METHODS within_ok      FOR TESTING.
    METHODS within_exceeds FOR TESTING.
    METHODS value_signed   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_count_variance IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_count_variance( ).
  ENDMETHOD.

  METHOD gain_signed.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->variance( iv_book = 100 iv_counted = 110 ) exp = 10 ).
  ENDMETHOD.

  METHOD loss_signed.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->variance( iv_book = 100 iv_counted = 90 ) exp = -10 ).
  ENDMETHOD.

  METHOD percent_abs.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->variance_percent( iv_book = 100 iv_counted = 90 )
      exp = 10 ).
  ENDMETHOD.

  METHOD percent_zero.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->variance_percent( iv_book = 0 iv_counted = 90 )
      exp = 0 ).
  ENDMETHOD.

  METHOD within_ok.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->within_tolerance( iv_book = 100 iv_counted = 95
                                      iv_tolerance_pct = 5 )
      exp = abap_true ).
  ENDMETHOD.

  METHOD within_exceeds.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->within_tolerance( iv_book = 100 iv_counted = 90
                                      iv_tolerance_pct = 5 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD value_signed.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->value_impact( iv_book = 100 iv_counted = 90
                                  iv_price_cents = 50 )
      exp = -500 ).
  ENDMETHOD.

ENDCLASS.
