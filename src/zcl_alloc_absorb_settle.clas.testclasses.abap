CLASS ltcl_alloc_absorb_settle DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_absorb_settle.

    METHODS setup.

    METHODS settles_amount FOR TESTING.
    METHODS reads_residual FOR TESTING.
    METHODS settled_rule   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_absorb_settle IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_absorb_settle( ).
  ENDMETHOD.

  METHOD settles_amount.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->settle( iv_absorbed = 600 iv_actual = 500 )
      exp = 500 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->settle( iv_absorbed = 400 iv_actual = 500 )
      exp = 400 ).
  ENDMETHOD.

  METHOD reads_residual.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->residual( iv_absorbed = 600 iv_actual = 500 )
      exp = 100 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->residual( iv_absorbed = 400 iv_actual = 500 )
      exp = 100 ).
  ENDMETHOD.

  METHOD settled_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_settled( 0 ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_settled( 100 ) exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
