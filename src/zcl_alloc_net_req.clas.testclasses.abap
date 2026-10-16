CLASS ltcl_alloc_net_req DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_net_req.

    METHODS setup.

    METHODS computes_net     FOR TESTING.
    METHODS computes_shortfall FOR TESTING.
    METHODS covered_rule     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_net_req IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_net_req( ).
  ENDMETHOD.

  METHOD computes_net.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->net( iv_gross = 100 iv_on_hand = 60 iv_scheduled = 10 )
      exp = 30 ).
  ENDMETHOD.

  METHOD computes_shortfall.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->shortfall( iv_gross = 100 iv_on_hand = 60 iv_scheduled = 10
                               iv_safety = 10 )
      exp = 40 ).
  ENDMETHOD.

  METHOD covered_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_covered( iv_gross = 100 iv_on_hand = 60 iv_scheduled = 10 )
      exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_covered( iv_gross = 100 iv_on_hand = 60 iv_scheduled = 50 )
      exp = abap_true ).
  ENDMETHOD.

ENDCLASS.
