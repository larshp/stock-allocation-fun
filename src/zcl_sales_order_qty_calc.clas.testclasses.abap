CLASS ltcl_sales_order_qty_calc DEFINITION FINAL
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_sales_order_qty_calc.
    METHODS setup.
    METHODS subtracts_delivered_quantity FOR TESTING.
    METHODS keeps_unfulfilled_qty FOR TESTING.
    METHODS complete_item_is_closed FOR TESTING.
    METHODS ignores_non_delivery_item FOR TESTING.
    METHODS clamps_overdelivery_to_zero FOR TESTING.
    METHODS rejects_unknown_status FOR TESTING.
    METHODS rejects_negative_quantities FOR TESTING.
ENDCLASS.

CLASS ltcl_sales_order_qty_calc IMPLEMENTATION.
  METHOD setup.
    mo_cut = NEW zcl_sales_order_qty_calc( ).
  ENDMETHOD.

  METHOD subtracts_delivered_quantity.
    DATA(ls_result) = mo_cut->calculate_open_quantity(
      iv_ordered_quantity   = '10.000'
      iv_delivered_quantity = '3.000'
      iv_delivery_status    = 'B' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '7.000' )
      act = ls_result-open_quantity ).
  ENDMETHOD.

  METHOD keeps_unfulfilled_qty.
    DATA(ls_result) = mo_cut->calculate_open_quantity(
      iv_ordered_quantity   = '10.000'
      iv_delivered_quantity = '0.000'
      iv_delivery_status    = 'A' ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '10.000' )
      act = ls_result-open_quantity ).
  ENDMETHOD.

  METHOD complete_item_is_closed.
    DATA(ls_result) = mo_cut->calculate_open_quantity(
      iv_ordered_quantity   = '10.000'
      iv_delivered_quantity = '6.000'
      iv_delivery_status    = 'C' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_result-open_quantity ).
  ENDMETHOD.

  METHOD ignores_non_delivery_item.
    DATA(ls_result) = mo_cut->calculate_open_quantity(
      iv_ordered_quantity   = '10.000'
      iv_delivered_quantity = '0.000'
      iv_delivery_status    = space ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_result-open_quantity ).
  ENDMETHOD.

  METHOD clamps_overdelivery_to_zero.
    DATA(ls_result) = mo_cut->calculate_open_quantity(
      iv_ordered_quantity   = '10.000'
      iv_delivered_quantity = '11.000'
      iv_delivery_status    = 'B' ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_result-open_quantity ).
  ENDMETHOD.

  METHOD rejects_unknown_status.
    DATA(ls_result) = mo_cut->calculate_open_quantity(
      iv_ordered_quantity   = '10.000'
      iv_delivered_quantity = '3.000'
      iv_delivery_status    = 'X' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
  ENDMETHOD.

  METHOD rejects_negative_quantities.
    DATA(ls_result) = mo_cut->calculate_open_quantity(
      iv_ordered_quantity   = '-1.000'
      iv_delivered_quantity = '0.000'
      iv_delivery_status    = 'A' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
  ENDMETHOD.
ENDCLASS.
