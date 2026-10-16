CLASS ltcl_alloc_service_target DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_service_target.

    METHODS setup.

    METHODS targets      FOR TESTING.
    METHODS met_rule     FOR TESTING.
    METHODS computes_gap FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_service_target IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_service_target( ).
  ENDMETHOD.

  METHOD targets.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->target_of( 'A' ) exp = 98 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->target_of( 'C' ) exp = 90 ).
  ENDMETHOD.

  METHOD met_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_met( iv_actual_percent = 98 iv_target = 98 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_met( iv_actual_percent = 90 iv_target = 98 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD computes_gap.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->gap( iv_actual_percent = 90 iv_target = 95 )
      exp = 5 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->gap( iv_actual_percent = 99 iv_target = 95 )
      exp = 0 ).
  ENDMETHOD.

ENDCLASS.
