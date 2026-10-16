CLASS ltcl_alloc_dock_slot DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_dock_slot.

    METHODS setup.

    METHODS slot_at_start    FOR TESTING.
    METHODS slot_midway      FOR TESTING.
    METHODS slot_boundary    FOR TESTING.
    METHODS start_of_slot    FOR TESTING.
    METHODS end_of_slot      FOR TESTING.
    METHODS zero_length      FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_dock_slot IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_dock_slot( ).
  ENDMETHOD.

  METHOD slot_at_start.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->slot_of( iv_arrival = 0 iv_slot_length = 30 )
      exp = 0 ).
  ENDMETHOD.

  METHOD slot_midway.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->slot_of( iv_arrival = 70 iv_slot_length = 30 )
      exp = 2 ).
  ENDMETHOD.

  METHOD slot_boundary.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->slot_of( iv_arrival = 60 iv_slot_length = 30 )
      exp = 2 ).
  ENDMETHOD.

  METHOD start_of_slot.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->slot_start( iv_slot = 2 iv_slot_length = 30 )
      exp = 60 ).
  ENDMETHOD.

  METHOD end_of_slot.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->slot_end( iv_slot = 2 iv_slot_length = 30 )
      exp = 90 ).
  ENDMETHOD.

  METHOD zero_length.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->slot_of( iv_arrival = 70 iv_slot_length = 0 )
      exp = 0 ).
  ENDMETHOD.

ENDCLASS.
