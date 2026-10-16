CLASS ltcl_alloc_return_policy DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_return_policy.

    METHODS setup.

    METHODS preset_values   FOR TESTING.
    METHODS window_lookup   FOR TESTING.
    METHODS fee_lookup      FOR TESTING.
    METHODS unknown_tier    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_return_policy IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_return_policy( ).
  ENDMETHOD.

  METHOD preset_values.
    DATA ls_policy TYPE zcl_alloc_return_policy=>ty_policy.

    ls_policy = mo_cut->preset( 'STANDARD' ).

    cl_abap_unit_assert=>assert_equals( act = ls_policy-name exp = 'STANDARD' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_policy-window_days exp = 30 ).
    cl_abap_unit_assert=>assert_equals( act = ls_policy-fee_percent exp = 0 ).
  ENDMETHOD.

  METHOD window_lookup.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->window_days( 'PREMIUM' ) exp = 60 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->window_days( 'CLEARANCE' ) exp = 14 ).
  ENDMETHOD.

  METHOD fee_lookup.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->fee_percent( 'CLEARANCE' ) exp = 10 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->fee_percent( 'STANDARD' ) exp = 0 ).
  ENDMETHOD.

  METHOD unknown_tier.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->window_days( 'NOPE' ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->fee_percent( 'NOPE' ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
