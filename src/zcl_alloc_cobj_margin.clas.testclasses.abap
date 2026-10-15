CLASS ltcl_alloc_cobj_margin DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_cobj_margin.

    METHODS setup.

    METHODS computes_margin  FOR TESTING.
    METHODS reads_percent    FOR TESTING.
    METHODS positive_rule    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_cobj_margin IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_cobj_margin( ).
  ENDMETHOD.

  METHOD computes_margin.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->margin( iv_revenue = 1000 iv_cost = 900 )
      exp = 100 ).
  ENDMETHOD.

  METHOD reads_percent.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->margin_percent( iv_revenue = 1000 iv_cost = 900 )
      exp = 10 ).
  ENDMETHOD.

  METHOD positive_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_positive( 100 ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_positive( -50 ) exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
