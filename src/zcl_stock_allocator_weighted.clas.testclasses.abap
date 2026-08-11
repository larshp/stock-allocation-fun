CLASS ltcl_stock_allocator_weighted DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS weights_priority_share FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS caps_demands FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS consumes_precision_residual FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS protects_fractional_stock FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_duplicate_keys FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_high_priority FOR TESTING
      RAISING zcx_stock_allocation.
ENDCLASS.

CLASS ltcl_stock_allocator_weighted IMPLEMENTATION.
  METHOD weights_priority_share.
    DATA lo_cut TYPE REF TO zif_stock_allocation.
    DATA lt_demands TYPE zif_stock_allocation=>tt_demands.

    CREATE OBJECT lo_cut TYPE zcl_stock_allocator_weighted.
    APPEND VALUE #( order_id = 'HIGH' priority = 2 requested = 10 )
      TO lt_demands.
    APPEND VALUE #( order_id = 'LOW' priority = 0 requested = 10 )
      TO lt_demands.

    lo_cut->allocate(
      EXPORTING
        iv_available = 8
      CHANGING
        ct_demands   = lt_demands ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ order_id = 'HIGH' ]-allocated
      exp = 6 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ order_id = 'LOW' ]-allocated
      exp = 2 ).
  ENDMETHOD.

  METHOD caps_demands.
    DATA lo_cut TYPE REF TO zif_stock_allocation.
    DATA lt_demands TYPE zif_stock_allocation=>tt_demands.

    CREATE OBJECT lo_cut TYPE zcl_stock_allocator_weighted.
    APPEND VALUE #( order_id = 'HIGH' priority = 10 requested = 1 )
      TO lt_demands.
    APPEND VALUE #( order_id = 'LOW' priority = 0 requested = 9 )
      TO lt_demands.

    lo_cut->allocate(
      EXPORTING
        iv_available = 5
      CHANGING
        ct_demands   = lt_demands ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ order_id = 'HIGH' ]-allocated
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ order_id = 'LOW' ]-allocated
      exp = 4 ).
  ENDMETHOD.

  METHOD protects_fractional_stock.
    DATA lo_cut TYPE REF TO zif_stock_allocation.
    DATA lt_demands TYPE zif_stock_allocation=>tt_demands.
    DATA lv_remaining TYPE zif_stock_allocation=>ty_quantity.
    DATA lv_allocated TYPE zif_stock_allocation=>ty_quantity.
    DATA lv_nonnegative TYPE abap_bool.
    DATA lv_within_stock TYPE abap_bool.

    CREATE OBJECT lo_cut TYPE zcl_stock_allocator_weighted.
    APPEND VALUE #( order_id = 'A' priority = 4 requested = 9 ) TO lt_demands.
    APPEND VALUE #( order_id = 'B' priority = 0 requested = 9 ) TO lt_demands.

    lv_remaining = lo_cut->allocate(
      EXPORTING
        iv_available = '0.001'
      CHANGING
        ct_demands   = lt_demands ).
    lv_allocated = lt_demands[ 1 ]-allocated
      + lt_demands[ 2 ]-allocated.

    lv_nonnegative = xsdbool( lv_remaining >= 0 ).
    lv_within_stock = xsdbool( lv_allocated <= '0.001' ).
    cl_abap_unit_assert=>assert_true( lv_nonnegative ).
    cl_abap_unit_assert=>assert_true( lv_within_stock ).
  ENDMETHOD.

  METHOD consumes_precision_residual.
    DATA lo_cut TYPE REF TO zif_stock_allocation.
    DATA lt_demands TYPE zif_stock_allocation=>tt_demands.
    DATA lv_remaining TYPE zif_stock_allocation=>ty_quantity.
    DATA lv_allocated TYPE zif_stock_allocation=>ty_quantity.

    CREATE OBJECT lo_cut TYPE zcl_stock_allocator_weighted.
    APPEND VALUE #( order_id = 'A' priority = 4 requested = 9 ) TO lt_demands.
    APPEND VALUE #( order_id = 'B' priority = 2 requested = 9 ) TO lt_demands.
    APPEND VALUE #( order_id = 'C' priority = 0 requested = 9 ) TO lt_demands.

    lv_remaining = lo_cut->allocate(
      EXPORTING
        iv_available = '1.001'
      CHANGING
        ct_demands   = lt_demands ).
    lv_allocated = lt_demands[ 1 ]-allocated
      + lt_demands[ 2 ]-allocated
      + lt_demands[ 3 ]-allocated.

    cl_abap_unit_assert=>assert_equals(
      act = lv_remaining
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_allocated
      exp = '1.001' ).
  ENDMETHOD.

  METHOD rejects_duplicate_keys.
    DATA lo_cut TYPE REF TO zif_stock_allocation.
    DATA lt_demands TYPE zif_stock_allocation=>tt_demands.
    DATA lv_raised TYPE abap_bool.

    CREATE OBJECT lo_cut TYPE zcl_stock_allocator_weighted.
    APPEND VALUE #( order_id = 'DUPLICATE' requested = 1 ) TO lt_demands.
    APPEND VALUE #( order_id = 'DUPLICATE' requested = 2 ) TO lt_demands.
    TRY.
        lo_cut->allocate(
          EXPORTING
            iv_available = 3
          CHANGING
            ct_demands   = lt_demands ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_error->message
          exp = 'Allocation demand keys are duplicated' ).
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
  ENDMETHOD.

  METHOD rejects_high_priority.
    DATA lo_cut TYPE REF TO zif_stock_allocation.
    DATA lt_demands TYPE zif_stock_allocation=>tt_demands.
    DATA lv_raised TYPE abap_bool.

    CREATE OBJECT lo_cut TYPE zcl_stock_allocator_weighted.
    APPEND VALUE #( order_id = 'TOO-HIGH' priority = 100 requested = 1 )
      TO lt_demands.
    TRY.
        lo_cut->allocate(
          EXPORTING
            iv_available = 1
          CHANGING
            ct_demands   = lt_demands ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_error->message
          exp = 'Allocation demand is invalid' ).
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
  ENDMETHOD.
ENDCLASS.
