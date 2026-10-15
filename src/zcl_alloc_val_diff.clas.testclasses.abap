CLASS ltcl_alloc_val_diff DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_val_diff.

    METHODS setup.

    METHODS computes_diff   FOR TESTING.
    METHODS up_rule         FOR TESTING.
    METHODS computes_percent FOR TESTING.
    METHODS guards_zero     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_val_diff IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_val_diff( ).
  ENDMETHOD.

  METHOD computes_diff.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->difference( iv_old_value = 1600 iv_new_value = 1500 )
      exp = -100 ).
  ENDMETHOD.

  METHOD up_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_up( iv_old_value = 1000 iv_new_value = 1100 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_up( iv_old_value = 1600 iv_new_value = 1500 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD computes_percent.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->percent( iv_old_value = 1000 iv_new_value = 1100 )
      exp = 10 ).
  ENDMETHOD.

  METHOD guards_zero.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->percent( iv_old_value = 0 iv_new_value = 1100 )
      exp = 0 ).
  ENDMETHOD.

ENDCLASS.
