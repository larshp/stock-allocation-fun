CLASS ltcl_alloc_minmax DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_minmax.

    METHODS setup.

    METHODS below_min      FOR TESTING.
    METHODS order_quantity FOR TESTING.
    METHODS target_rule    FOR TESTING.
    METHODS guards_full    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_minmax IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_minmax( ).
  ENDMETHOD.

  METHOD below_min.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_below_min( iv_stock = 5 iv_min = 10 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_below_min( iv_stock = 15 iv_min = 10 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD order_quantity.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->order_quantity( iv_stock = 5 iv_max = 100 )
      exp = 95 ).
  ENDMETHOD.

  METHOD target_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->target( iv_stock = 5 iv_min = 10 iv_max = 100 )
      exp = 100 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->target( iv_stock = 50 iv_min = 10 iv_max = 100 )
      exp = 50 ).
  ENDMETHOD.

  METHOD guards_full.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->order_quantity( iv_stock = 120 iv_max = 100 )
      exp = 0 ).
  ENDMETHOD.

ENDCLASS.
