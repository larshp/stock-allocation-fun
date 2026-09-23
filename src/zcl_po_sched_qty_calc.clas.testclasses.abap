CLASS ltcl_po_sched_qty_calc DEFINITION FINAL
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS converts_open_order_quantity FOR TESTING.
    METHODS converts_fractional_base_qty FOR TESTING.
    METHODS converts_open_issued_quantity FOR TESTING.
    METHODS clamps_closed_schedule FOR TESTING.
    METHODS skips_invalid_conversion FOR TESTING.
ENDCLASS.

CLASS ltcl_po_sched_qty_calc IMPLEMENTATION.

  METHOD converts_open_order_quantity.
    DATA(lo_cut) = NEW zcl_po_sched_qty_calc( ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '36.000' )
      act = lo_cut->calculate_open_base_quantity(
        iv_scheduled_quantity  = '5.000'
        iv_received_quantity   = '2.000'
        iv_order_to_base_num   = 12
        iv_order_to_base_denom = 1 ) ).
  ENDMETHOD.

  METHOD converts_fractional_base_qty.
    DATA(lo_cut) = NEW zcl_po_sched_qty_calc( ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1.500' )
      act = lo_cut->calculate_open_base_quantity(
        iv_scheduled_quantity  = '3.000'
        iv_received_quantity   = '0.000'
        iv_order_to_base_num   = 1
        iv_order_to_base_denom = 2 ) ).
  ENDMETHOD.

  METHOD converts_open_issued_quantity.
    DATA(lo_cut) = NEW zcl_po_sched_qty_calc( ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '18.000' )
      act = lo_cut->calculate_open_issued_qty(
        iv_issued_quantity     = '5.000'
        iv_received_quantity   = '3.500'
        iv_order_to_base_num   = 12
        iv_order_to_base_denom = 1 ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( 0 )
      act = lo_cut->calculate_open_issued_qty(
        iv_issued_quantity     = '0.000'
        iv_received_quantity   = '0.000'
        iv_order_to_base_num   = 12
        iv_order_to_base_denom = 1 ) ).
  ENDMETHOD.

  METHOD clamps_closed_schedule.
    DATA(lo_cut) = NEW zcl_po_sched_qty_calc( ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( 0 )
      act = lo_cut->calculate_open_base_quantity(
        iv_scheduled_quantity  = '4.000'
        iv_received_quantity   = '5.000'
        iv_order_to_base_num   = 12
        iv_order_to_base_denom = 1 ) ).
  ENDMETHOD.

  METHOD skips_invalid_conversion.
    DATA(lo_cut) = NEW zcl_po_sched_qty_calc( ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( 0 )
      act = lo_cut->calculate_open_base_quantity(
        iv_scheduled_quantity  = '4.000'
        iv_received_quantity   = '1.000'
        iv_order_to_base_num   = 0
        iv_order_to_base_denom = 1 ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( 0 )
      act = lo_cut->calculate_open_base_quantity(
        iv_scheduled_quantity  = '4.000'
        iv_received_quantity   = '1.000'
        iv_order_to_base_num   = 12
        iv_order_to_base_denom = 0 ) ).
  ENDMETHOD.

ENDCLASS.
