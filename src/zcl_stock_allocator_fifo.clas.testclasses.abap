CLASS ltcl_stock_allocator_fifo DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS allocates_oldest_first FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS same_date_uses_priority FOR TESTING
      RAISING zcx_stock_allocation.
ENDCLASS.

CLASS ltcl_stock_allocator_fifo IMPLEMENTATION.
  METHOD allocates_oldest_first.
    DATA lo_cut TYPE REF TO zif_stock_allocation.
    DATA lt_demands TYPE zif_stock_allocation=>tt_demands.

    CREATE OBJECT lo_cut TYPE zcl_stock_allocator_fifo.
    APPEND VALUE #( order_id     = 'RECENT'
                    priority     = 10
                    requested_on = '20260102'
                    requested    = '8' ) TO lt_demands.
    APPEND VALUE #( order_id     = 'OLDEST'
                    priority     = 1
                    requested_on = '20260101'
                    requested    = '5' ) TO lt_demands.

    lo_cut->allocate(
      EXPORTING
        iv_available = '7'
      CHANGING
        ct_demands   = lt_demands ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ order_id = 'OLDEST' ]-allocated
      exp = '5' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ order_id = 'RECENT' ]-allocated
      exp = '2' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ 1 ]-order_id
      exp = 'OLDEST' ).
  ENDMETHOD.

  METHOD same_date_uses_priority.
    DATA lo_cut TYPE REF TO zif_stock_allocation.
    DATA lt_demands TYPE zif_stock_allocation=>tt_demands.

    CREATE OBJECT lo_cut TYPE zcl_stock_allocator_fifo.
    APPEND VALUE #( order_id     = 'LOW'
                    priority     = 1
                    requested_on = '20260101'
                    requested    = '1' ) TO lt_demands.
    APPEND VALUE #( order_id     = 'HIGH'
                    priority     = 10
                    requested_on = '20260101'
                    requested    = '1' ) TO lt_demands.

    lo_cut->allocate(
      EXPORTING
        iv_available = '1'
      CHANGING
        ct_demands   = lt_demands ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ 1 ]-order_id
      exp = 'HIGH' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ order_id = 'HIGH' ]-allocation_status
      exp = 'F' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ order_id = 'LOW' ]-allocation_status
      exp = 'U' ).
  ENDMETHOD.
ENDCLASS.
