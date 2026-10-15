CLASS ltcl_alloc_margin_rate DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_margin_rate.

    METHODS setup.

    METHODS reads_rate     FOR TESTING.
    METHODS prices_for_rate FOR TESTING.
    METHODS healthy_rule   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_margin_rate IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_margin_rate( ).
  ENDMETHOD.

  METHOD reads_rate.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->rate( iv_margin = 500 iv_revenue = 1500 )
      exp = 33 ).
  ENDMETHOD.

  METHOD prices_for_rate.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->price( iv_cost = 800 iv_rate_percent = 20 )
      exp = 1000 ).
  ENDMETHOD.

  METHOD healthy_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_healthy( iv_rate = 33 iv_min_rate = 20 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_healthy( iv_rate = 10 iv_min_rate = 20 )
      exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
