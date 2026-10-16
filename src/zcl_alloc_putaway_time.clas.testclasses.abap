CLASS ltcl_alloc_putaway_time DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_putaway_time.

    METHODS setup.

    METHODS total_reads   FOR TESTING.
    METHODS travel_once   FOR TESTING.
    METHODS average_reads FOR TESTING.
    METHODS zero_tasks    FOR TESTING.
    METHODS within_flag   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_putaway_time IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_putaway_time( ).
  ENDMETHOD.

  METHOD total_reads.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total_minutes( iv_tasks = 10 iv_minutes_per_task = 3
                                   iv_travel_minutes = 20 )
      exp = 50 ).
  ENDMETHOD.

  METHOD travel_once.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total_minutes( iv_tasks = 1 iv_minutes_per_task = 3
                                   iv_travel_minutes = 20 )
      exp = 23 ).
  ENDMETHOD.

  METHOD average_reads.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->per_task( iv_tasks = 10 iv_minutes_per_task = 3
                              iv_travel_minutes = 20 )
      exp = 5 ).
  ENDMETHOD.

  METHOD zero_tasks.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total_minutes( iv_tasks = 0 iv_minutes_per_task = 3
                                   iv_travel_minutes = 20 )
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->per_task( iv_tasks = 0 iv_minutes_per_task = 3
                              iv_travel_minutes = 20 )
      exp = 0 ).
  ENDMETHOD.

  METHOD within_flag.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_within( iv_minutes = 50 iv_target = 60 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_within( iv_minutes = 70 iv_target = 60 )
      exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
