CLASS ltcl_alloc_interco_margin DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_interco_margin.

    METHODS setup.

    METHODS computes_margin   FOR TESTING.
    METHODS eliminated_rule   FOR TESTING.
    METHODS computes_percent  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_interco_margin IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_interco_margin( ).
  ENDMETHOD.

  METHOD computes_margin.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->margin( iv_transfer_price = 1100 iv_cost = 1000 )
      exp = 100 ).
  ENDMETHOD.

  METHOD eliminated_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_eliminated( abap_false ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_eliminated( abap_true ) exp = abap_false ).
  ENDMETHOD.

  METHOD computes_percent.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->percent( iv_transfer_price = 1100 iv_cost = 1000 )
      exp = 9 ).
  ENDMETHOD.

ENDCLASS.
