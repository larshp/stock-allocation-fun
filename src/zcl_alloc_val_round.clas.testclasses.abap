CLASS ltcl_alloc_val_round DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_val_round.

    METHODS setup.

    METHODS rounds_value   FOR TESTING.
    METHODS rounds_up      FOR TESTING.
    METHODS computes_diff  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_val_round IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_val_round( ).
  ENDMETHOD.

  METHOD rounds_value.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->round( iv_value = 103 iv_nearest = 5 ) exp = 105 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->round( iv_value = 102 iv_nearest = 5 ) exp = 100 ).
  ENDMETHOD.

  METHOD rounds_up.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->nearest( iv_value = 102 iv_nearest = 5 ) exp = 105 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->nearest( iv_value = 105 iv_nearest = 5 ) exp = 105 ).
  ENDMETHOD.

  METHOD computes_diff.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->difference( iv_value = 102 iv_nearest = 5 ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->difference( iv_value = 105 iv_nearest = 5 ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
