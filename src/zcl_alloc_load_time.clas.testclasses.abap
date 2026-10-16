CLASS ltcl_alloc_load_time DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_load_time.

    METHODS setup.

    METHODS estimate_rate FOR TESTING.
    METHODS includes_setup FOR TESTING.
    METHODS zero_items   FOR TESTING.
    METHODS hours_read    FOR TESTING.
    METHODS minutes_read  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_load_time IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_load_time( ).
  ENDMETHOD.

  METHOD estimate_rate.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->estimate( iv_items = 10 iv_seconds_per_item = 30
                              iv_setup = 0 )
      exp = 300 ).
  ENDMETHOD.

  METHOD includes_setup.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->estimate( iv_items = 10 iv_seconds_per_item = 30
                              iv_setup = 120 )
      exp = 420 ).
  ENDMETHOD.

  METHOD zero_items.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->estimate( iv_items = 0 iv_seconds_per_item = 30
                              iv_setup = 120 )
      exp = 0 ).
  ENDMETHOD.

  METHOD hours_read.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->hours( iv_seconds = 5400 ) exp = 1 ).
  ENDMETHOD.

  METHOD minutes_read.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->minutes( iv_seconds = 5400 ) exp = 30 ).
  ENDMETHOD.

ENDCLASS.
