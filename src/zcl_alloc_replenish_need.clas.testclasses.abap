CLASS ltcl_alloc_replenish_need DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_replenish_need.

    METHODS setup.

    METHODS computes_need   FOR TESTING.
    METHODS needed_rule     FOR TESTING.
    METHODS computes_shortfall FOR TESTING.
    METHODS guards_covered  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_replenish_need IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_replenish_need( ).
  ENDMETHOD.

  METHOD computes_need.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->need( iv_required = 100 iv_available = 80 )
      exp = 20 ).
  ENDMETHOD.

  METHOD needed_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_needed( iv_required = 100 iv_available = 80 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_needed( iv_required = 80 iv_available = 100 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD computes_shortfall.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->shortfall( iv_required = 100 iv_available = 80 iv_safety = 10 )
      exp = 30 ).
  ENDMETHOD.

  METHOD guards_covered.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->need( iv_required = 80 iv_available = 100 )
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->shortfall( iv_required = 100 iv_available = 100 iv_safety = 0 )
      exp = 0 ).
  ENDMETHOD.

ENDCLASS.
