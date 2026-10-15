CLASS ltcl_alloc_valm_drift DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_valm_drift.

    METHODS setup.

    METHODS computes_drift  FOR TESTING.
    METHODS drifting_rule   FOR TESTING.
    METHODS reads_direction FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_valm_drift IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_valm_drift( ).
  ENDMETHOD.

  METHOD computes_drift.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->drift( iv_target = 1000 iv_actual = 1100 )
      exp = 100 ).
  ENDMETHOD.

  METHOD drifting_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_drifting( iv_target = 1000 iv_actual = 1100
                                 iv_tolerance = 50 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_drifting( iv_target = 1000 iv_actual = 1030
                                 iv_tolerance = 50 )
      exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_drifting( iv_target = 1000 iv_actual = 900
                                 iv_tolerance = 50 )
      exp = abap_true ).
  ENDMETHOD.

  METHOD reads_direction.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->direction( iv_target = 1000 iv_actual = 1100 )
      exp = 'OVER' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->direction( iv_target = 1000 iv_actual = 900 )
      exp = 'UNDER' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->direction( iv_target = 1000 iv_actual = 1000 )
      exp = 'ON' ).
  ENDMETHOD.

ENDCLASS.
