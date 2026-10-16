CLASS ltcl_alloc_drv_normalize DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_drv_normalize.

    METHODS setup.

    METHODS computes_factor FOR TESTING.
    METHODS scales_value    FOR TESTING.
    METHODS normal_rule     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_drv_normalize IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_drv_normalize( ).
  ENDMETHOD.

  METHOD computes_factor.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->factor( iv_total = 500 iv_target = 1000 )
      exp = 200 ).
  ENDMETHOD.

  METHOD scales_value.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->normalize( iv_value = 100 iv_total = 500 iv_target = 1000 )
      exp = 200 ).
  ENDMETHOD.

  METHOD normal_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_normal( iv_total = 1000 iv_target = 1000 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_normal( iv_total = 500 iv_target = 1000 )
      exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
