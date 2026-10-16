CLASS ltcl_alloc_prep_kpi DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_prep_kpi.

    METHODS setup.

    METHODS computes_value FOR TESTING.
    METHODS on_target_rule FOR TESTING.
    METHODS computes_gap   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_prep_kpi IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_prep_kpi( ).
  ENDMETHOD.

  METHOD computes_value.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->value_of( iv_actual = 90 iv_target = 100 ) exp = 90 ).
  ENDMETHOD.

  METHOD on_target_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_on_target( iv_actual = 100 iv_target = 100 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_on_target( iv_actual = 90 iv_target = 100 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD computes_gap.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->gap( iv_actual = 90 iv_target = 100 ) exp = 10 ).
  ENDMETHOD.

ENDCLASS.
