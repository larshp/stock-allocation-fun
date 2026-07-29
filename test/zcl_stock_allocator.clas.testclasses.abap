CLASS ltcl_stock_allocator DEFINITION FINAL FOR TESTING
    RISK LEVEL HARMLESS DURATION SHORT.
  PRIVATE SECTION.
    METHODS allocates_by_priority FOR TESTING.
    METHODS consumes_earliest_batch FOR TESTING.
    METHODS excludes_unavailable_stock FOR TESTING.
ENDCLASS.

CLASS ltcl_stock_allocator IMPLEMENTATION.
  METHOD allocates_by_priority.
    DATA(stocks) = VALUE zcl_sap_atp_rules=>ty_stocks(
      ( material = `MAT-1` plant = `1000` batch = `B1`
        expiry_date = '20261231' unrestricted_qty = 10 ) ).
    DATA(demands) = VALUE zcl_stock_allocator=>ty_demands(
      ( request_id = `LOW` material = `MAT-1` plant = `1000`
        requirement_date = '20260801' priority = 2 requested_qty = 7 )
      ( request_id = `HIGH` material = `MAT-1` plant = `1000`
        requirement_date = '20260802' priority = 1 requested_qty = 6 ) ).

    DATA(result) = zcl_stock_allocator=>allocate(
      demands = demands
      stocks = stocks
      allocation_date = '20260729' ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( result )
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = result[ 1 ]-request_id
      exp = `HIGH` ).
    cl_abap_unit_assert=>assert_equals(
      act = result[ 1 ]-allocated_qty
      exp = 6 ).
    cl_abap_unit_assert=>assert_equals(
      act = result[ 2 ]-allocated_qty
      exp = 4 ).
    cl_abap_unit_assert=>assert_equals(
      act = result[ 3 ]-shortage_qty
      exp = 3 ).
  ENDMETHOD.

  METHOD consumes_earliest_batch.
    DATA(stocks) = VALUE zcl_sap_atp_rules=>ty_stocks(
      ( material = `MAT-1` plant = `1000` batch = `LATE`
        expiry_date = '20261231' unrestricted_qty = 5 )
      ( material = `MAT-1` plant = `1000` batch = `EARLY`
        expiry_date = '20261031' unrestricted_qty = 5 ) ).
    DATA(demands) = VALUE zcl_stock_allocator=>ty_demands(
      ( request_id = `ONE` material = `MAT-1` plant = `1000`
        requirement_date = '20260801' priority = 1 requested_qty = 7 ) ).

    DATA(result) = zcl_stock_allocator=>allocate(
      demands = demands
      stocks = stocks
      allocation_date = '20260729' ).

    cl_abap_unit_assert=>assert_equals(
      act = result[ 1 ]-batch
      exp = `EARLY` ).
    cl_abap_unit_assert=>assert_equals(
      act = result[ 1 ]-allocated_qty
      exp = 5 ).
    cl_abap_unit_assert=>assert_equals(
      act = result[ 2 ]-batch
      exp = `LATE` ).
    cl_abap_unit_assert=>assert_equals(
      act = result[ 2 ]-allocated_qty
      exp = 2 ).
  ENDMETHOD.

  METHOD excludes_unavailable_stock.
    DATA(stocks) = VALUE zcl_sap_atp_rules=>ty_stocks(
      ( material = `MAT-1` plant = `1000` batch = `EXPIRED`
        expiry_date = '20260101' unrestricted_qty = 8 )
      ( material = `MAT-1` plant = `1000` batch = `VALID`
        expiry_date = '20261231' unrestricted_qty = 9 safety_stock = 4
        quality_qty = 10 blocked_qty = 10 ) ).
    DATA(demands) = VALUE zcl_stock_allocator=>ty_demands(
      ( request_id = `ONE` material = `MAT-1` plant = `1000`
        requirement_date = '20260801' priority = 1 requested_qty = 7 ) ).

    DATA(result) = zcl_stock_allocator=>allocate(
      demands = demands
      stocks = stocks
      allocation_date = '20260729' ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( result )
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = result[ 1 ]-batch
      exp = `VALID` ).
    cl_abap_unit_assert=>assert_equals(
      act = result[ 1 ]-allocated_qty
      exp = 5 ).
    cl_abap_unit_assert=>assert_equals(
      act = result[ 2 ]-shortage_qty
      exp = 2 ).
  ENDMETHOD.
ENDCLASS.
