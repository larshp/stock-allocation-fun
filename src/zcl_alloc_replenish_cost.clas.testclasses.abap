CLASS ltcl_alloc_replenish_cost DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_replenish_cost.

    METHODS setup.

    METHODS sums_total   FOR TESTING.
    METHODS shares       FOR TESTING.
    METHODS guards_input FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_replenish_cost IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_replenish_cost( ).
  ENDMETHOD.

  METHOD sums_total.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total( iv_ordering = 300 iv_holding = 200 )
      exp = 500 ).
  ENDMETHOD.

  METHOD shares.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->ordering_share( iv_ordering = 300 iv_holding = 200 )
      exp = 60 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->holding_share( iv_ordering = 300 iv_holding = 200 )
      exp = 40 ).
  ENDMETHOD.

  METHOD guards_input.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total( iv_ordering = 0 iv_holding = 0 )
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->ordering_share( iv_ordering = 0 iv_holding = 0 )
      exp = 0 ).
  ENDMETHOD.

ENDCLASS.
