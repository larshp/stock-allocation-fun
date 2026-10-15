CLASS ltcl_alloc_pick_rate DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_pick_rate.

    METHODS setup.

    METHODS per_hour_read   FOR TESTING.
    METHODS per_hour_faster FOR TESTING.
    METHODS per_minute_read FOR TESTING.
    METHODS minutes_for     FOR TESTING.
    METHODS zero_guards     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_pick_rate IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_pick_rate( ).
  ENDMETHOD.

  METHOD per_hour_read.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->per_hour( iv_lines = 120 iv_minutes = 60 ) exp = 120 ).
  ENDMETHOD.

  METHOD per_hour_faster.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->per_hour( iv_lines = 120 iv_minutes = 30 ) exp = 240 ).
  ENDMETHOD.

  METHOD per_minute_read.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->per_minute( iv_lines = 120 iv_minutes = 60 ) exp = 2 ).
  ENDMETHOD.

  METHOD minutes_for.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->minutes_for( iv_lines = 120 iv_rate_per_hour = 120 )
      exp = 60 ).
  ENDMETHOD.

  METHOD zero_guards.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->per_hour( iv_lines = 120 iv_minutes = 0 ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->minutes_for( iv_lines = 120 iv_rate_per_hour = 0 )
      exp = 0 ).
  ENDMETHOD.

ENDCLASS.
