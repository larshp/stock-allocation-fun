CLASS ltcl_stock_allocator_full DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS skips_partial_lines FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS fills_later_line_when_it_fits FOR TESTING
      RAISING zcx_stock_allocation.
ENDCLASS.

CLASS ltcl_stock_allocator_full IMPLEMENTATION.
  METHOD skips_partial_lines.
    DATA lo_cut TYPE REF TO zif_stock_allocation.
    DATA lt_demands TYPE zif_stock_allocation=>tt_demands.
    DATA lv_remaining TYPE zif_stock_allocation=>ty_quantity.

    CREATE OBJECT lo_cut TYPE zcl_stock_allocator_full.
    APPEND VALUE #( order_id     = 'LARGE'
                    priority     = 10
                    requested_on = '20260101'
                    requested    = '8' ) TO lt_demands.
    APPEND VALUE #( order_id     = 'SMALL'
                    priority     = 1
                    requested_on = '20260102'
                    requested    = '5' ) TO lt_demands.

    lv_remaining = lo_cut->allocate(
      EXPORTING
        iv_available = '7'
      CHANGING
        ct_demands   = lt_demands ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ order_id = 'LARGE' ]-allocation_status
      exp = 'U' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ order_id = 'SMALL' ]-allocation_status
      exp = 'F' ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_remaining
      exp = '2' ).
  ENDMETHOD.

  METHOD fills_later_line_when_it_fits.
    DATA lo_cut TYPE REF TO zif_stock_allocation.
    DATA lt_demands TYPE zif_stock_allocation=>tt_demands.

    CREATE OBJECT lo_cut TYPE zcl_stock_allocator_full.
    APPEND VALUE #( order_id  = 'LARGE'
                    priority  = 10
                    requested = '8' ) TO lt_demands.
    APPEND VALUE #( order_id  = 'SMALL'
                    priority  = 1
                    requested = '2' ) TO lt_demands.

    lo_cut->allocate(
      EXPORTING
        iv_available = '2'
      CHANGING
        ct_demands   = lt_demands ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ order_id = 'LARGE' ]-allocation_status
      exp = 'U' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ order_id = 'SMALL' ]-allocation_status
      exp = 'F' ).
  ENDMETHOD.
ENDCLASS.
