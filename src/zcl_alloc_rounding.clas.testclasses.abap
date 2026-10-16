CLASS ltcl_alloc_rounding DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_rounding.

    METHODS setup.

    METHODS nearest_down     FOR TESTING.
    METHODS nearest_up       FOR TESTING.
    METHODS nearest_exact    FOR TESTING.
    METHODS up_rounds        FOR TESTING.
    METHODS up_exact_keeps   FOR TESTING.
    METHODS down_rounds      FOR TESTING.
    METHODS zero_step_keeps  FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_rounding IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_rounding( ).
  ENDMETHOD.

  METHOD nearest_down.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->round_to( iv_value = '7' iv_step = '5' )
      exp = '5' ).
  ENDMETHOD.

  METHOD nearest_up.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->round_to( iv_value = '8' iv_step = '5' )
      exp = '10' ).
  ENDMETHOD.

  METHOD nearest_exact.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->round_to( iv_value = '10' iv_step = '5' )
      exp = '10' ).
  ENDMETHOD.

  METHOD up_rounds.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->round_up_to( iv_value = '7' iv_step = '5' )
      exp = '10' ).
  ENDMETHOD.

  METHOD up_exact_keeps.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->round_up_to( iv_value = '10' iv_step = '5' )
      exp = '10' ).
  ENDMETHOD.

  METHOD down_rounds.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->round_down_to( iv_value = '7' iv_step = '5' )
      exp = '5' ).
  ENDMETHOD.

  METHOD zero_step_keeps.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->round_to( iv_value = '7' iv_step = '0' )
      exp = '7' ).
  ENDMETHOD.

ENDCLASS.
