CLASS ltcl_alloc_shelf_life DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_shelf_life.

    METHODS setup.

    METHODS days_left       FOR TESTING.
    METHODS days_floor_zero FOR TESTING.
    METHODS on_expiry_day   FOR TESTING.
    METHODS past_expiry_day FOR TESTING.
    METHODS usable_enough   FOR TESTING.
    METHODS usable_too_late FOR TESTING.
    METHODS expiring_soon   FOR TESTING.
    METHODS expiring_no     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_shelf_life IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_shelf_life( ).
  ENDMETHOD.

  METHOD days_left.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->remaining_days( iv_today = 100 iv_expiry = 130 )
      exp = 30 ).
  ENDMETHOD.

  METHOD days_floor_zero.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->remaining_days( iv_today = 200 iv_expiry = 130 )
      exp = 0 ).
  ENDMETHOD.

  METHOD on_expiry_day.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_expired( iv_today = 130 iv_expiry = 130 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD past_expiry_day.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_expired( iv_today = 131 iv_expiry = 130 )
      exp = abap_true ).
  ENDMETHOD.

  METHOD usable_enough.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_usable( iv_today = 100 iv_expiry = 130
                               iv_min_remaining = 20 )
      exp = abap_true ).
  ENDMETHOD.

  METHOD usable_too_late.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_usable( iv_today = 100 iv_expiry = 130
                               iv_min_remaining = 40 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD expiring_soon.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_expiring( iv_today = 100 iv_expiry = 110
                                 iv_warn_days = 15 )
      exp = abap_true ).
  ENDMETHOD.

  METHOD expiring_no.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_expiring( iv_today = 100 iv_expiry = 200
                                 iv_warn_days = 15 )
      exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
