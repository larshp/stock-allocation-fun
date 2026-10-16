CLASS ltcl_alloc_copro_credit DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_copro_credit.

    METHODS setup.

    METHODS computes_credit FOR TESTING.
    METHODS credited_rule   FOR TESTING.
    METHODS computes_net    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_copro_credit IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_copro_credit( ).
  ENDMETHOD.

  METHOD computes_credit.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->credit( iv_joint_cost = 1000 iv_by_product_val = 100 )
      exp = 900 ).
  ENDMETHOD.

  METHOD credited_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_credited( 900 ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_credited( 0 ) exp = abap_false ).
  ENDMETHOD.

  METHOD computes_net.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->net_cost( iv_joint_cost = 1000 iv_credit = 900 )
      exp = 100 ).
  ENDMETHOD.

ENDCLASS.
