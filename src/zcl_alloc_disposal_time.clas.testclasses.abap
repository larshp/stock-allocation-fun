CLASS ltcl_alloc_disposal_time DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_disposal_time.

    METHODS setup.

    METHODS computes_lead  FOR TESTING.
    METHODS lead_guard     FOR TESTING.
    METHODS urgency_rule   FOR TESTING.
    METHODS plans_day      FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_disposal_time IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_disposal_time( ).
  ENDMETHOD.

  METHOD computes_lead.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->lead_days( iv_base_days = 2 iv_quantity = 3
                               iv_per_unit_days = 1 )
      exp = 5 ).
  ENDMETHOD.

  METHOD lead_guard.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->lead_days( iv_base_days = -1 iv_quantity = 3
                               iv_per_unit_days = 1 )
      exp = 0 ).
  ENDMETHOD.

  METHOD urgency_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_urgent( iv_days = 3 iv_limit = 5 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_urgent( iv_days = 10 iv_limit = 5 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD plans_day.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->planned_day( iv_start = '20260101' iv_days = 3 )
      exp = '20260104' ).
  ENDMETHOD.

ENDCLASS.
