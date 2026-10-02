CLASS ltcl_pr_open_qty_calc DEFINITION FINAL
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS calculates_open_base_quantity FOR TESTING.
ENDCLASS.

CLASS ltcl_pr_open_qty_calc IMPLEMENTATION.
  METHOD calculates_open_base_quantity.
    DATA(lo_cut) = NEW zcl_pr_open_qty_calc( ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '6.000' )
      act = lo_cut->calculate_open_base_quantity(
        iv_requested_quantity = CONV eban-menge( '10.000' )
        iv_ordered_quantity   = CONV eban-bsmng( '4.000' )
        iv_unit_to_base_num   = 1
        iv_unit_to_base_denom = 1 ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '15.000' )
      act = lo_cut->calculate_open_base_quantity(
        iv_requested_quantity = CONV eban-menge( '10.000' )
        iv_ordered_quantity   = CONV eban-bsmng( '4.000' )
        iv_unit_to_base_num   = 5
        iv_unit_to_base_denom = 2 ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0.000' )
      act = lo_cut->calculate_open_base_quantity(
        iv_requested_quantity = CONV eban-menge( '10.000' )
        iv_ordered_quantity   = CONV eban-bsmng( '10.000' )
        iv_unit_to_base_num   = 1
        iv_unit_to_base_denom = 1 ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0.000' )
      act = lo_cut->calculate_open_base_quantity(
        iv_requested_quantity = CONV eban-menge( '10.000' )
        iv_ordered_quantity   = CONV eban-bsmng( '4.000' )
        iv_unit_to_base_num   = 0
        iv_unit_to_base_denom = 1 ) ).
  ENDMETHOD.
ENDCLASS.
