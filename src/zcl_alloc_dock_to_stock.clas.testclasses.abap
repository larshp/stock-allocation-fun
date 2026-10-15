CLASS ltcl_alloc_dock_to_stock DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_dock_to_stock.

    METHODS setup.

    METHODS elapsed_read  FOR TESTING.
    METHODS elapsed_floor FOR TESTING.
    METHODS on_target_yes FOR TESTING.
    METHODS on_target_no  FOR TESTING.
    METHODS class_target  FOR TESTING.
    METHODS class_slow    FOR TESTING.
    METHODS class_late    FOR TESTING.
    METHODS class_no_tgt  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_dock_to_stock IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_dock_to_stock( ).
  ENDMETHOD.

  METHOD elapsed_read.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->elapsed_minutes( iv_arrival = 100 iv_completion = 145 )
      exp = 45 ).
  ENDMETHOD.

  METHOD elapsed_floor.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->elapsed_minutes( iv_arrival = 100 iv_completion = 90 )
      exp = 0 ).
  ENDMETHOD.

  METHOD on_target_yes.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_on_target( iv_minutes = 45 iv_target = 60 )
      exp = abap_true ).
  ENDMETHOD.

  METHOD on_target_no.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_on_target( iv_minutes = 70 iv_target = 60 )
      exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_on_target( iv_minutes = 70 iv_target = 0 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD class_target.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->classify( iv_minutes = 45 iv_target = 60 )
      exp = 'ON_TARGET' ).
  ENDMETHOD.

  METHOD class_slow.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->classify( iv_minutes = 90 iv_target = 60 )
      exp = 'SLOW' ).
  ENDMETHOD.

  METHOD class_late.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->classify( iv_minutes = 130 iv_target = 60 )
      exp = 'LATE' ).
  ENDMETHOD.

  METHOD class_no_tgt.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->classify( iv_minutes = 10 iv_target = 0 )
      exp = '' ).
  ENDMETHOD.

ENDCLASS.
