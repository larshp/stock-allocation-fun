CLASS ltcl_alloc_settle_balance DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_settle_balance.

    METHODS setup.

    METHODS computes_balance FOR TESTING.
    METHODS balanced_rule    FOR TESTING.
    METHODS computes_residual FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_settle_balance IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_settle_balance( ).
  ENDMETHOD.

  METHOD computes_balance.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->balance( iv_debit = 100 iv_credit = 90 ) exp = 10 ).
  ENDMETHOD.

  METHOD balanced_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_balanced( 0 ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_balanced( 10 ) exp = abap_false ).
  ENDMETHOD.

  METHOD computes_residual.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->residual( iv_debit = 90 iv_credit = 100 ) exp = 10 ).
  ENDMETHOD.

ENDCLASS.
