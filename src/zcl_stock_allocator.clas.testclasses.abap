CLASS ltcl_allocator DEFINITION FINAL FOR TESTING DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS full_quantity FOR TESTING.
    METHODS shortage FOR TESTING.
    METHODS zero_stock FOR TESTING.
    METHODS negative_stock FOR TESTING.
    METHODS negative_request FOR TESTING.
ENDCLASS.

CLASS ltcl_allocator IMPLEMENTATION.
  METHOD full_quantity.
    DATA(quantity) = zcl_stock_allocator=>allocate( iv_available_qty = 20 iv_requested_qty = 10 ).
    cl_abap_unit_assert=>assert_equals( act = quantity exp = 10 ).
  ENDMETHOD.

  METHOD shortage.
    DATA(quantity) = zcl_stock_allocator=>allocate( iv_available_qty = 3 iv_requested_qty = 10 ).
    cl_abap_unit_assert=>assert_equals( act = quantity exp = 3 ).
  ENDMETHOD.

  METHOD zero_stock.
    DATA(quantity) = zcl_stock_allocator=>allocate( iv_available_qty = 0 iv_requested_qty = 10 ).
    cl_abap_unit_assert=>assert_equals( act = quantity exp = 0 ).
  ENDMETHOD.

  METHOD negative_stock.
    DATA(quantity) = zcl_stock_allocator=>allocate( iv_available_qty = -1 iv_requested_qty = 10 ).
    cl_abap_unit_assert=>assert_equals( act = quantity exp = 0 ).
  ENDMETHOD.

  METHOD negative_request.
    DATA(quantity) = zcl_stock_allocator=>allocate( iv_available_qty = 10 iv_requested_qty = -1 ).
    cl_abap_unit_assert=>assert_equals( act = quantity exp = 0 ).
  ENDMETHOD.
ENDCLASS.

CLASS ltcl_plan DEFINITION FINAL FOR TESTING DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS stock_1000 RETURNING VALUE(rt_stock) TYPE zif_stock_reader=>ty_stock_tt.
    METHODS priority_order FOR TESTING.
    METHODS safety_stock FOR TESTING.
    METHODS full_delivery FOR TESTING.
    METHODS horizon FOR TESTING.
    METHODS multi_location FOR TESTING.
    METHODS empty_material FOR TESTING.
    METHODS summary_totals FOR TESTING.
    METHODS summary_no_shortage FOR TESTING.
    METHODS input_stock_unchanged FOR TESTING.
    METHODS wrong_material_ignored FOR TESTING.
    METHODS wrong_plant_ignored FOR TESTING.
    METHODS wrong_client_ignored FOR TESTING.
    METHODS reserve_exceeds_stock FOR TESTING.
    METHODS zero_quantity_requirement FOR TESTING.
ENDCLASS.

CLASS ltcl_plan IMPLEMENTATION.
  METHOD stock_1000.
    rt_stock = VALUE #(
      ( mandt = sy-mandt matnr = 'MAT1' werks = '1000' lgort = '0001' labst = '4.500' )
      ( mandt = sy-mandt matnr = 'MAT1' werks = '1000' lgort = '0002' labst = '8.250' ) ).
  ENDMETHOD.

  METHOD priority_order.
    DATA(reqs) = VALUE zcl_stock_allocator=>ty_requirements(
      ( order_id = '0000000001' item_id = '000001' quantity = '10.000' priority = 2 due_date = '20260101' )
      ( order_id = '0000000002' item_id = '000002' quantity = '5.000' priority = 1 due_date = '20260101' ) ).
    DATA(plan) = zcl_stock_allocator=>plan(
      it_stock        = stock_1000( )
      it_requirements = reqs
      iv_material     = 'MAT1'
      iv_plant        = '1000' ).
    READ TABLE plan-results INDEX 1 INTO DATA(first).
    cl_abap_unit_assert=>assert_equals( act = first-requirement-item_id exp = '000002' ).
    cl_abap_unit_assert=>assert_equals( act = first-allocated exp = '5.000' ).
    READ TABLE plan-results INDEX 2 INTO DATA(second).
    cl_abap_unit_assert=>assert_equals( act = second-allocated exp = '7.750' ).
    cl_abap_unit_assert=>assert_equals( act = second-shortage exp = '2.250' ).
  ENDMETHOD.

  METHOD safety_stock.
    DATA(reqs) = VALUE zcl_stock_allocator=>ty_requirements(
      ( order_id = '0000000001' item_id = '000001' quantity = '10.000' priority = 1 due_date = '20260101' ) ).
    DATA(plan) = zcl_stock_allocator=>plan(
      it_stock        = stock_1000( )
      it_requirements = reqs
      iv_material     = 'MAT1'
      iv_plant        = '1000'
      iv_safety_stock = '5.000' ).
    READ TABLE plan-results INDEX 1 INTO DATA(result).
    cl_abap_unit_assert=>assert_equals( act = result-allocated exp = '7.750' ).
    cl_abap_unit_assert=>assert_equals( act = result-shortage exp = '2.250' ).
    cl_abap_unit_assert=>assert_equals( act = lines( plan-picks ) exp = 1 ).
    READ TABLE plan-picks INDEX 1 INTO DATA(pick).
    cl_abap_unit_assert=>assert_equals( act = pick-location exp = '0002' ).
    cl_abap_unit_assert=>assert_equals( act = pick-quantity exp = '7.750' ).
  ENDMETHOD.

  METHOD full_delivery.
    DATA(reqs) = VALUE zcl_stock_allocator=>ty_requirements(
      ( order_id = '0000000001' item_id = '000001' quantity = '20.000' priority = 1 due_date = '20260101' )
      ( order_id = '0000000002' item_id = '000002' quantity = '10.000' priority = 2 due_date = '20260101' ) ).
    DATA(plan) = zcl_stock_allocator=>plan(
      it_stock         = stock_1000( )
      it_requirements  = reqs
      iv_material      = 'MAT1'
      iv_plant         = '1000'
      iv_full_delivery = abap_true ).
    READ TABLE plan-results INDEX 1 INTO DATA(first).
    cl_abap_unit_assert=>assert_equals( act = first-allocated exp = '0.000' ).
    cl_abap_unit_assert=>assert_equals( act = first-shortage exp = '20.000' ).
    READ TABLE plan-results INDEX 2 INTO DATA(second).
    cl_abap_unit_assert=>assert_equals( act = second-allocated exp = '10.000' ).
  ENDMETHOD.

  METHOD horizon.
    DATA(reqs) = VALUE zcl_stock_allocator=>ty_requirements(
      ( order_id = '0000000001' item_id = '000001' quantity = '5.000' priority = 1 due_date = '20260201' )
      ( order_id = '0000000002' item_id = '000002' quantity = '5.000' priority = 2 due_date = '20260101' ) ).
    DATA(plan) = zcl_stock_allocator=>plan(
      it_stock        = stock_1000( )
      it_requirements = reqs
      iv_material     = 'MAT1'
      iv_plant        = '1000'
      iv_horizon      = '20260101' ).
    READ TABLE plan-results INDEX 1 INTO DATA(first).
    cl_abap_unit_assert=>assert_equals( act = first-deferred exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = first-allocated exp = '0.000' ).
    READ TABLE plan-results INDEX 2 INTO DATA(second).
    cl_abap_unit_assert=>assert_equals( act = second-allocated exp = '5.000' ).
  ENDMETHOD.

  METHOD multi_location.
    DATA(reqs) = VALUE zcl_stock_allocator=>ty_requirements(
      ( order_id = '0000000001' item_id = '000001' quantity = '5.000' priority = 1 due_date = '20260101' ) ).
    DATA(plan) = zcl_stock_allocator=>plan(
      it_stock        = stock_1000( )
      it_requirements = reqs
      iv_material     = 'MAT1'
      iv_plant        = '1000' ).
    cl_abap_unit_assert=>assert_equals( act = lines( plan-picks ) exp = 2 ).
    READ TABLE plan-picks INDEX 1 INTO DATA(pick).
    cl_abap_unit_assert=>assert_equals( act = pick-location exp = '0001' ).
    cl_abap_unit_assert=>assert_equals( act = pick-quantity exp = '4.500' ).
    READ TABLE plan-picks INDEX 2 INTO DATA(second).
    cl_abap_unit_assert=>assert_equals( act = second-location exp = '0002' ).
    cl_abap_unit_assert=>assert_equals( act = second-quantity exp = '0.500' ).
  ENDMETHOD.

  METHOD empty_material.
    DATA(reqs) = VALUE zcl_stock_allocator=>ty_requirements(
      ( order_id = '0000000001' item_id = '000001' quantity = '5.000' priority = 1 due_date = '20260101' ) ).
    DATA(plan) = zcl_stock_allocator=>plan(
      it_stock        = stock_1000( )
      it_requirements = reqs
      iv_material     = ''
      iv_plant        = '1000' ).
    cl_abap_unit_assert=>assert_initial( plan-picks ).
    cl_abap_unit_assert=>assert_initial( plan-results ).
  ENDMETHOD.
ENDCLASS.
