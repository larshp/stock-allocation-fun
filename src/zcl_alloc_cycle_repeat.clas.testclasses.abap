CLASS ltcl_alloc_cycle_repeat DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_cycle_repeat.

    METHODS setup.

    METHODS repeats_cycle  FOR TESTING.
    METHODS repeated_rule  FOR TESTING.
    METHODS max_rule       FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_cycle_repeat IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_cycle_repeat( ).
  ENDMETHOD.

  METHOD repeats_cycle.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->repeat( iv_count = 1 iv_max = 5 ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->repeat( iv_count = 5 iv_max = 5 ) exp = 5 ).
  ENDMETHOD.

  METHOD repeated_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_repeated( 2 ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_repeated( 0 ) exp = abap_false ).
  ENDMETHOD.

  METHOD max_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->max_reached( iv_count = 5 iv_max = 5 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->max_reached( iv_count = 3 iv_max = 5 )
      exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
