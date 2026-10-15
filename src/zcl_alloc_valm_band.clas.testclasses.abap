CLASS ltcl_alloc_valm_band DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_valm_band.

    METHODS setup.

    METHODS band_rule      FOR TESTING.
    METHODS reads_position FOR TESTING.
    METHODS computes_gap   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_valm_band IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_valm_band( ).
  ENDMETHOD.

  METHOD band_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_in_band( iv_value = 1200 iv_lower = 1000 iv_upper = 1500 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_in_band( iv_value = 1600 iv_lower = 1000 iv_upper = 1500 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD reads_position.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->position( iv_value = 900 iv_lower = 1000 iv_upper = 1500 )
      exp = 'BELOW' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->position( iv_value = 1200 iv_lower = 1000 iv_upper = 1500 )
      exp = 'INSIDE' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->position( iv_value = 1600 iv_lower = 1000 iv_upper = 1500 )
      exp = 'ABOVE' ).
  ENDMETHOD.

  METHOD computes_gap.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->band_gap( iv_value = 1600 iv_lower = 1000 iv_upper = 1500 )
      exp = 100 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->band_gap( iv_value = 900 iv_lower = 1000 iv_upper = 1500 )
      exp = 100 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->band_gap( iv_value = 1200 iv_lower = 1000 iv_upper = 1500 )
      exp = 0 ).
  ENDMETHOD.

ENDCLASS.
