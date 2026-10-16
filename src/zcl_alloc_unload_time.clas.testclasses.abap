CLASS ltcl_alloc_unload_time DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_unload_time.

    METHODS setup.

    METHODS both_rates   FOR TESTING.
    METHODS only_fixed   FOR TESTING.
    METHODS hours_read    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_unload_time IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_unload_time( ).
  ENDMETHOD.

  METHOD both_rates.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->estimate( iv_units = 2 iv_items = 10
                              iv_seconds_per_unit = 60
                              iv_seconds_per_item = 5
                              iv_fixed = 30 )
      exp = 200 ).
  ENDMETHOD.

  METHOD only_fixed.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->estimate( iv_units = 0 iv_items = 0
                              iv_seconds_per_unit = 60
                              iv_seconds_per_item = 5
                              iv_fixed = 45 )
      exp = 45 ).
  ENDMETHOD.

  METHOD hours_read.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->hours( iv_seconds = 7200 ) exp = 2 ).
  ENDMETHOD.

ENDCLASS.
