CLASS ltcl_alloc_pallet_check DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_pallet_check.

    METHODS setup.

    METHODS within_limits FOR TESTING.
    METHODS too_high      FOR TESTING.
    METHODS too_heavy     FOR TESTING.
    METHODS both_broken   FOR TESTING.
    METHODS no_limits     FOR TESTING.
    METHODS at_the_limit  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_pallet_check IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_pallet_check( ).
  ENDMETHOD.

  METHOD within_limits.
    DATA ls_result TYPE zcl_alloc_pallet_check=>ty_result.

    ls_result = mo_cut->check( iv_height = 100 iv_weight = 500
                               iv_max_height = 120 iv_max_weight = 600 ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-ok exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-too_high exp = abap_false ).
  ENDMETHOD.

  METHOD too_high.
    DATA ls_result TYPE zcl_alloc_pallet_check=>ty_result.

    ls_result = mo_cut->check( iv_height = 130 iv_weight = 500
                               iv_max_height = 120 iv_max_weight = 600 ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-ok exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-too_high exp = abap_true ).
  ENDMETHOD.

  METHOD too_heavy.
    DATA ls_result TYPE zcl_alloc_pallet_check=>ty_result.

    ls_result = mo_cut->check( iv_height = 100 iv_weight = 700
                               iv_max_height = 120 iv_max_weight = 600 ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-ok exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-too_heavy exp = abap_true ).
  ENDMETHOD.

  METHOD both_broken.
    DATA ls_result TYPE zcl_alloc_pallet_check=>ty_result.

    ls_result = mo_cut->check( iv_height = 130 iv_weight = 700
                               iv_max_height = 120 iv_max_weight = 600 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_result-too_high exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-too_heavy exp = abap_true ).
  ENDMETHOD.

  METHOD no_limits.
    DATA ls_result TYPE zcl_alloc_pallet_check=>ty_result.

    ls_result = mo_cut->check( iv_height = 999 iv_weight = 9999
                               iv_max_height = 0 iv_max_weight = 0 ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-ok exp = abap_true ).
  ENDMETHOD.

  METHOD at_the_limit.
    DATA ls_result TYPE zcl_alloc_pallet_check=>ty_result.

    ls_result = mo_cut->check( iv_height = 120 iv_weight = 600
                               iv_max_height = 120 iv_max_weight = 600 ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-ok exp = abap_true ).
  ENDMETHOD.

ENDCLASS.
