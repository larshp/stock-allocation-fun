CLASS ltcl_alloc_order_multiple DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_order_multiple.

    METHODS setup.

    METHODS aligns        FOR TESTING.
    METHODS computes_remainder FOR TESTING.
    METHODS aligned_rule  FOR TESTING.
    METHODS guards_input  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_order_multiple IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_order_multiple( ).
  ENDMETHOD.

  METHOD aligns.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->align( iv_quantity = 13 iv_multiple = 5 )
      exp = 15 ).
  ENDMETHOD.

  METHOD computes_remainder.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->remainder( iv_quantity = 13 iv_multiple = 5 )
      exp = 3 ).
  ENDMETHOD.

  METHOD aligned_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_aligned( iv_quantity = 15 iv_multiple = 5 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_aligned( iv_quantity = 13 iv_multiple = 5 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD guards_input.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->remainder( iv_quantity = 13 iv_multiple = 0 )
      exp = 0 ).
  ENDMETHOD.

ENDCLASS.
