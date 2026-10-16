CLASS ltcl_alloc_landed_unit DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_landed_unit.

    METHODS setup.

    METHODS computes_unit    FOR TESTING.
    METHODS high_rule        FOR TESTING.
    METHODS compares_standard FOR TESTING.
    METHODS guards_zero      FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_landed_unit IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_landed_unit( ).
  ENDMETHOD.

  METHOD computes_unit.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->per_unit( iv_landed_total = 1200 iv_quantity = 150 )
      exp = 8 ).
  ENDMETHOD.

  METHOD high_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_high( iv_landed_unit = 8 iv_standard_unit = 7 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_high( iv_landed_unit = 6 iv_standard_unit = 7 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD compares_standard.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->vs_standard( iv_landed_unit = 8 iv_standard_unit = 7 )
      exp = 1 ).
  ENDMETHOD.

  METHOD guards_zero.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->per_unit( iv_landed_total = 1200 iv_quantity = 0 )
      exp = 0 ).
  ENDMETHOD.

ENDCLASS.
