CLASS ltcl_alloc_cpool_rate DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_cpool_rate.

    METHODS setup.

    METHODS computes_rate FOR TESTING.
    METHODS applies_rate  FOR TESTING.
    METHODS zero_rule     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_cpool_rate IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_cpool_rate( ).
  ENDMETHOD.

  METHOD computes_rate.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->rate( iv_pool = 900 iv_quantity = 300 )
      exp = 3 ).
  ENDMETHOD.

  METHOD applies_rate.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->applied( iv_rate = 3 iv_quantity = 300 )
      exp = 900 ).
  ENDMETHOD.

  METHOD zero_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_zero( 0 ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_zero( 3 ) exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
