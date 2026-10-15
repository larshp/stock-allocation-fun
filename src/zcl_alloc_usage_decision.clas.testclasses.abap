CLASS ltcl_alloc_usage_decision DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_usage_decision.

    METHODS setup.

    METHODS clean_is_a      FOR TESTING.
    METHODS low_is_b        FOR TESTING.
    METHODS mid_is_c        FOR TESTING.
    METHODS high_is_d       FOR TESTING.
    METHODS accepted_codes  FOR TESTING.
    METHODS rejected_codes  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_usage_decision IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_usage_decision( ).
  ENDMETHOD.

  METHOD clean_is_a.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->decide( iv_defect_rate = 0 ) exp = 'A' ).
  ENDMETHOD.

  METHOD low_is_b.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->decide( iv_defect_rate = 2 ) exp = 'B' ).
  ENDMETHOD.

  METHOD mid_is_c.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->decide( iv_defect_rate = 5 ) exp = 'C' ).
  ENDMETHOD.

  METHOD high_is_d.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->decide( iv_defect_rate = 6 ) exp = 'D' ).
  ENDMETHOD.

  METHOD accepted_codes.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_accepted( iv_code = 'A' ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_accepted( iv_code = 'B' ) exp = abap_true ).
  ENDMETHOD.

  METHOD rejected_codes.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_accepted( iv_code = 'C' ) exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_accepted( iv_code = 'D' ) exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
