CLASS ltcl_alloc_return_policy_res DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_return_policy_res.
    DATA mt_rul TYPE zcl_alloc_return_policy_res=>ty_rule_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_tier     TYPE string
        iv_priority TYPE string
        iv_window   TYPE i
        iv_fee      TYPE i.

    METHODS resolves_specific FOR TESTING.
    METHODS resolves_tier     FOR TESTING.
    METHODS resolves_global   FOR TESTING.
    METHODS tier_helpers      FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_return_policy_res IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_return_policy_res( ).

    add( iv_tier = '' iv_priority = '' iv_window = 60 iv_fee = 0 ).
    add( iv_tier = 'GOLD' iv_priority = '' iv_window = 30 iv_fee = 0 ).
    add( iv_tier = 'GOLD' iv_priority = 'EXPRESS' iv_window = 14 iv_fee = 5 ).
  ENDMETHOD.

  METHOD add.
    DATA ls_rule TYPE zcl_alloc_return_policy_res=>ty_rule.

    ls_rule-tier = iv_tier.
    ls_rule-priority = iv_priority.
    ls_rule-window_days = iv_window.
    ls_rule-fee_percent = iv_fee.
    APPEND ls_rule TO mt_rul.
  ENDMETHOD.

  METHOD resolves_specific.
    DATA ls_policy TYPE zcl_alloc_return_policy_res=>ty_policy.

    ls_policy = mo_cut->resolve( it_rules    = mt_rul
                                 iv_tier     = 'GOLD'
                                 iv_priority = 'EXPRESS' ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_policy-window_days exp = 14 ).
    cl_abap_unit_assert=>assert_equals( act = ls_policy-fee_percent exp = 5 ).
  ENDMETHOD.

  METHOD resolves_tier.
    DATA ls_policy TYPE zcl_alloc_return_policy_res=>ty_policy.

    ls_policy = mo_cut->resolve( it_rules    = mt_rul
                                 iv_tier     = 'GOLD'
                                 iv_priority = '' ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_policy-window_days exp = 30 ).
  ENDMETHOD.

  METHOD resolves_global.
    DATA ls_policy TYPE zcl_alloc_return_policy_res=>ty_policy.

    ls_policy = mo_cut->resolve( it_rules    = mt_rul
                                 iv_tier     = 'SILVER'
                                 iv_priority = '' ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_policy-window_days exp = 60 ).
  ENDMETHOD.

  METHOD tier_helpers.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->window_of( it_rules = mt_rul iv_tier = 'GOLD' )
      exp = 30 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->fee_of( it_rules = mt_rul iv_tier = 'GOLD' )
      exp = 0 ).
  ENDMETHOD.

ENDCLASS.
