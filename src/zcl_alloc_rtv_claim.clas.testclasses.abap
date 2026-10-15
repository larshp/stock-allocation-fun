CLASS ltcl_alloc_rtv_claim DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_rtv_claim.

    METHODS setup.

    METHODS claim_value     FOR TESTING.
    METHODS claim_guard     FOR TESTING.
    METHODS approved_share  FOR TESTING.
    METHODS validity_rule   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_rtv_claim IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_rtv_claim( ).
  ENDMETHOD.

  METHOD claim_value.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->claim( iv_quantity = 3 iv_unit_cost = 7 )
      exp = 21 ).
  ENDMETHOD.

  METHOD claim_guard.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->claim( iv_quantity = 0 iv_unit_cost = 7 )
      exp = 0 ).
  ENDMETHOD.

  METHOD approved_share.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->value( iv_claim = 100 iv_approved_percent = 80 )
      exp = 80 ).
  ENDMETHOD.

  METHOD validity_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_valid( iv_claim = 21 iv_limit = 50 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_valid( iv_claim = 60 iv_limit = 50 )
      exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_valid( iv_claim = 0 iv_limit = 50 )
      exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
