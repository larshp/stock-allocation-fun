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
