CLASS ltcl_alloc_replenish_schedule DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_replenish_schedule.

    METHODS setup.

    METHODS schedules_next FOR TESTING.
    METHODS schedules_nth  FOR TESTING.
    METHODS overdue_rule   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_replenish_schedule IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_replenish_schedule( ).
  ENDMETHOD.

  METHOD schedules_next.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->schedule( iv_last_date = '20260101' iv_cycle_days = 7 )
      exp = '20260108' ).
  ENDMETHOD.

  METHOD schedules_nth.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->next_date( iv_last_date = '20260101' iv_cycle_days = 7
                               iv_count = 2 )
      exp = '20260115' ).
  ENDMETHOD.

  METHOD overdue_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_overdue( iv_planned_date = '20260101'
                                iv_today        = '20260105' )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_overdue( iv_planned_date = '20260110'
                                iv_today        = '20260105' )
      exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
