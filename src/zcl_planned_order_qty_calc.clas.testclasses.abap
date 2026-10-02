CLASS ltcl_planned_order_qty_calc DEFINITION FINAL
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS converts_planned_quantity FOR TESTING.
    METHODS skips_invalid_conversion FOR TESTING.
ENDCLASS.

CLASS ltcl_planned_order_qty_calc IMPLEMENTATION.
  METHOD converts_planned_quantity.
    DATA(lo_cut) = NEW zcl_planned_order_qty_calc( ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '6.000' )
      act = lo_cut->calculate_open_base_quantity(
        iv_planned_quantity   = CONV plaf-gsmng( '3.000' )
        iv_unit_to_base_num   = 2
        iv_unit_to_base_denom = 1 ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1.500' )
      act = lo_cut->calculate_open_base_quantity(
        iv_planned_quantity   = CONV plaf-gsmng( '3.000' )
        iv_unit_to_base_num   = 1
        iv_unit_to_base_denom = 2 ) ).
  ENDMETHOD.

  METHOD skips_invalid_conversion.
    DATA(lo_cut) = NEW zcl_planned_order_qty_calc( ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( 0 )
      act = lo_cut->calculate_open_base_quantity(
        iv_planned_quantity   = CONV plaf-gsmng( '3.000' )
        iv_unit_to_base_num   = 0
        iv_unit_to_base_denom = 1 ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( 0 )
      act = lo_cut->calculate_open_base_quantity(
        iv_planned_quantity   = CONV plaf-gsmng( '0.000' )
        iv_unit_to_base_num   = 1
        iv_unit_to_base_denom = 1 ) ).
  ENDMETHOD.
ENDCLASS.
