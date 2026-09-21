CLASS ltcl_stock_allocator_small DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS allocates_smallest_first FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS same_quantity_uses_priority FOR TESTING
      RAISING zcx_stock_allocation.
ENDCLASS.

CLASS ltcl_stock_allocator_small IMPLEMENTATION.
  METHOD allocates_smallest_first.
    DATA lo_cut TYPE REF TO zif_stock_allocation.
    DATA lt_demands TYPE zif_stock_allocation=>tt_demands.

    CREATE OBJECT lo_cut TYPE zcl_stock_allocator_small.
    APPEND VALUE #( order_id  = 'LARGE'
                    priority  = 10
                    requested = '8' ) TO lt_demands.
    APPEND VALUE #( order_id  = 'SMALL'
                    priority  = 1
                    requested = '3' ) TO lt_demands.

    lo_cut->allocate(
      EXPORTING
        iv_available = '5'
      CHANGING
        ct_demands   = lt_demands ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ 1 ]-order_id
      exp = 'SMALL' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ order_id = 'SMALL' ]-allocation_status
      exp = 'F' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ order_id = 'LARGE' ]-allocated
      exp = '2' ).
  ENDMETHOD.

  METHOD same_quantity_uses_priority.
    DATA lo_cut TYPE REF TO zif_stock_allocation.
    DATA lt_demands TYPE zif_stock_allocation=>tt_demands.

    CREATE OBJECT lo_cut TYPE zcl_stock_allocator_small.
    APPEND VALUE #( order_id  = 'LOW'
                    priority  = 1
                    requested = '2' ) TO lt_demands.
    APPEND VALUE #( order_id  = 'HIGH'
                    priority  = 10
                    requested = '2' ) TO lt_demands.

    lo_cut->allocate(
      EXPORTING
        iv_available = '2'
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
