CLASS ltcl_allocator DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS allocates_partial_stock FOR TESTING RAISING zcx_salloc_invalid.
    METHODS rejects_negative_stock FOR TESTING.
    METHODS validation_is_atomic FOR TESTING.
    METHODS honors_priority_date_id FOR TESTING RAISING zcx_salloc_invalid.
ENDCLASS.

CLASS ltcl_allocator IMPLEMENTATION.
  METHOD allocates_partial_stock.
    DATA(demands) = VALUE zif_salloc_types=>tt_demands(
      ( order_id = '100' requested = 7 )
      ( order_id = '200' requested = 6 ) ).

    DATA(remaining) = zcl_salloc_allocator=>allocate(
      EXPORTING iv_available = 10
      CHANGING ct_demands = demands ).

    cl_abap_unit_assert=>assert_equals( act = demands[ 1 ]-allocated exp = 7 ).
    cl_abap_unit_assert=>assert_equals( act = demands[ 2 ]-allocated exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = remaining exp = 0 ).
  ENDMETHOD.

  METHOD rejects_negative_stock.
    DATA demands TYPE zif_salloc_types=>tt_demands.
    TRY.
        zcl_salloc_allocator=>allocate(
          EXPORTING iv_available = -1
          CHANGING ct_demands = demands ).
        cl_abap_unit_assert=>fail( `Expected invalid stock exception` ).
      CATCH zcx_salloc_invalid.
    ENDTRY.
  ENDMETHOD.

  METHOD validation_is_atomic.
    DATA(demands) = VALUE zif_salloc_types=>tt_demands(
      ( order_id = '100' requested = 2 allocated = 1 )
      ( order_id = '200' requested = -1 ) ).
    TRY.
        zcl_salloc_allocator=>allocate(
          EXPORTING iv_available = 5
          CHANGING ct_demands = demands ).
        cl_abap_unit_assert=>fail( `Expected invalid demand exception` ).
      CATCH zcx_salloc_invalid.
        cl_abap_unit_assert=>assert_equals( act = demands[ 1 ]-allocated exp = 1 ).
    ENDTRY.
  ENDMETHOD.

  METHOD honors_priority_date_id.
    DATA(demands) = VALUE zif_salloc_types=>tt_demands(
      ( order_id = 'C' priority = 1 requested_on = '20260101' requested = 4 )
      ( order_id = 'B' priority = 2 requested_on = '20260102' requested = 4 )
      ( order_id = 'A' priority = 2 requested_on = '20260101' requested = 4 ) ).

    zcl_salloc_allocator=>allocate(
      EXPORTING iv_available = 6
      CHANGING ct_demands = demands ).

    cl_abap_unit_assert=>assert_equals( act = demands[ 1 ]-order_id exp = 'A' ).
    cl_abap_unit_assert=>assert_equals( act = demands[ 1 ]-allocated exp = 4 ).
    cl_abap_unit_assert=>assert_equals( act = demands[ 2 ]-order_id exp = 'B' ).
    cl_abap_unit_assert=>assert_equals( act = demands[ 2 ]-allocated exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = demands[ 3 ]-allocated exp = 0 ).
  ENDMETHOD.
ENDCLASS.
