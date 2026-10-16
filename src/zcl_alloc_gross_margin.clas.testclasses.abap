CLASS ltcl_alloc_gross_margin DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_gross_margin.

    METHODS setup.

    METHODS computes_margin   FOR TESTING.
    METHODS computes_percent  FOR TESTING.
    METHODS positive_rule     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_gross_margin IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_gross_margin( ).
  ENDMETHOD.

  METHOD computes_margin.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->margin( iv_revenue = 1500 iv_cogs = 1000 )
      exp = 500 ).
  ENDMETHOD.

  METHOD computes_percent.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->margin_percent( iv_revenue = 1500 iv_cogs = 1000 )
      exp = 33 ).
  ENDMETHOD.

  METHOD positive_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_positive( iv_revenue = 1500 iv_cogs = 1000 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_positive( iv_revenue = 900 iv_cogs = 1000 )
      exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
