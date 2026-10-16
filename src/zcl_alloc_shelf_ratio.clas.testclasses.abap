CLASS ltcl_alloc_shelf_ratio DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_shelf_ratio.

    METHODS setup.

    METHODS half_left       FOR TESTING.
    METHODS full_life       FOR TESTING.
    METHODS over_full       FOR TESTING.
    METHODS zero_total      FOR TESTING.
    METHODS fresh_enough    FOR TESTING.
    METHODS not_fresh       FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_shelf_ratio IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_shelf_ratio( ).
  ENDMETHOD.

  METHOD half_left.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->ratio( iv_total_days     = 100
                           iv_remaining_days = 50 )
      exp = 50 ).
  ENDMETHOD.

  METHOD full_life.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->ratio( iv_total_days     = 100
                           iv_remaining_days = 100 )
      exp = 100 ).
  ENDMETHOD.

  METHOD over_full.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->ratio( iv_total_days     = 100
                           iv_remaining_days = 120 )
      exp = 120 ).
  ENDMETHOD.

  METHOD zero_total.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->ratio( iv_total_days = 0 iv_remaining_days = 50 )
      exp = 0 ).
  ENDMETHOD.

  METHOD fresh_enough.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_fresh( iv_total_days = 100 iv_remaining_days = 60
                              iv_min_pct = 50 )
      exp = abap_true ).
  ENDMETHOD.

  METHOD not_fresh.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_fresh( iv_total_days = 100 iv_remaining_days = 20
                              iv_min_pct = 50 )
      exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
