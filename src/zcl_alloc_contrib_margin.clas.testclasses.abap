CLASS ltcl_alloc_contrib_margin DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_contrib_margin.

    METHODS setup.

    METHODS computes_contribution FOR TESTING.
    METHODS computes_ratio        FOR TESTING.
    METHODS covers_fixed_rule     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_contrib_margin IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_contrib_margin( ).
  ENDMETHOD.

  METHOD computes_contribution.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->contribution( iv_revenue = 1500 iv_variable_cost = 900 )
      exp = 600 ).
  ENDMETHOD.

  METHOD computes_ratio.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->ratio( iv_revenue = 1500 iv_variable_cost = 900 )
      exp = 40 ).
  ENDMETHOD.

  METHOD covers_fixed_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->covers_fixed( iv_revenue = 1500 iv_variable_cost = 900
                                  iv_fixed_cost = 500 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->covers_fixed( iv_revenue = 1500 iv_variable_cost = 900
                                  iv_fixed_cost = 700 )
      exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
