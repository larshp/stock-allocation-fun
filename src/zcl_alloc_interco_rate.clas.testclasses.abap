CLASS ltcl_alloc_interco_rate DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_interco_rate.

    METHODS setup.

    METHODS reads_rate       FOR TESTING.
    METHODS applies_rate     FOR TESTING.
    METHODS reasonable_rule  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_interco_rate IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_interco_rate( ).
  ENDMETHOD.

  METHOD reads_rate.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->rate( iv_transfer_price = 1100 iv_cost = 1000 )
      exp = 10 ).
  ENDMETHOD.

  METHOD applies_rate.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->applied( iv_cost = 1000 iv_rate_percent = 10 )
      exp = 1100 ).
  ENDMETHOD.

  METHOD reasonable_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_reasonable( iv_rate_percent = 10 iv_max_percent = 20 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_reasonable( iv_rate_percent = 30 iv_max_percent = 20 )
      exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
