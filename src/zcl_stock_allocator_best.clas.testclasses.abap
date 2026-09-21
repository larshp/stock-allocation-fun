CLASS ltcl_stock_allocator_best DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS maximizes_full_lines FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS uses_priority_for_ties FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS falls_back_to_smallest FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_duplicate_keys FOR TESTING
      RAISING zcx_stock_allocation.
ENDCLASS.

CLASS ltcl_stock_allocator_best IMPLEMENTATION.
  METHOD maximizes_full_lines.
    DATA lo_cut TYPE REF TO zif_stock_allocation.
    DATA lt_demands TYPE zif_stock_allocation=>tt_demands.
    DATA lv_remaining TYPE zif_stock_allocation=>ty_quantity.

    CREATE OBJECT lo_cut TYPE zcl_stock_allocator_best.
    APPEND VALUE #( order_id  = 'SEVEN'
                    priority  = 10
                    requested = '7' ) TO lt_demands.
    APPEND VALUE #( order_id  = 'SIX'
                    priority  = 1
                    requested = '6' ) TO lt_demands.
    APPEND VALUE #( order_id  = 'FOUR'
                    priority  = 1
                    requested = '4' ) TO lt_demands.

    lv_remaining = lo_cut->allocate(
      EXPORTING
        iv_available = '10'
      CHANGING
        ct_demands   = lt_demands ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ 1 ]-order_id
      exp = 'SIX' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ 2 ]-order_id
      exp = 'FOUR' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ order_id = 'SIX' ]-allocation_status
      exp = 'F' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ order_id = 'FOUR' ]-allocation_status
      exp = 'F' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ order_id = 'SEVEN' ]-allocation_status
      exp = 'U' ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_remaining
      exp = '0' ).
  ENDMETHOD.

  METHOD uses_priority_for_ties.
    DATA lo_cut TYPE REF TO zif_stock_allocation.
    DATA lt_demands TYPE zif_stock_allocation=>tt_demands.

    CREATE OBJECT lo_cut TYPE zcl_stock_allocator_best.
    APPEND VALUE #( order_id  = 'LOW'
                    priority  = 1
                    requested = '5' ) TO lt_demands.
    APPEND VALUE #( order_id  = 'HIGH'
                    priority  = 10
                    requested = '5' ) TO lt_demands.

    lo_cut->allocate(
      EXPORTING
        iv_available = '5'
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

  METHOD falls_back_to_smallest.
    DATA lo_cut TYPE REF TO zif_stock_allocation.
    DATA lt_demands TYPE zif_stock_allocation=>tt_demands.
    DATA lv_remaining TYPE zif_stock_allocation=>ty_quantity.

    CREATE OBJECT lo_cut TYPE zcl_stock_allocator_best.
    APPEND VALUE #( order_id  = 'LARGE'
                    priority  = 10
                    requested = '5' ) TO lt_demands.
    APPEND VALUE #( order_id  = 'SMALL'
                    priority  = 1
                    requested = '4' ) TO lt_demands.

    lv_remaining = lo_cut->allocate(
      EXPORTING
        iv_available = '3'
      CHANGING
        ct_demands   = lt_demands ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ 1 ]-order_id
      exp = 'SMALL' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ order_id = 'SMALL' ]-allocated
      exp = '3' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ order_id = 'SMALL' ]-allocation_status
      exp = 'P' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ order_id = 'LARGE' ]-allocation_status
      exp = 'U' ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_remaining
      exp = '0' ).
  ENDMETHOD.

  METHOD rejects_duplicate_keys.
    DATA lo_cut TYPE REF TO zif_stock_allocation.
    DATA lt_demands TYPE zif_stock_allocation=>tt_demands.
    DATA lv_raised TYPE abap_bool.
    DATA lv_message TYPE c LENGTH 220.

    CREATE OBJECT lo_cut TYPE zcl_stock_allocator_best.
    APPEND VALUE #( order_id  = 'DUPLICATE'
                    requested = '1' ) TO lt_demands.
    APPEND VALUE #( order_id  = 'DUPLICATE'
                    requested = '2' ) TO lt_demands.
    TRY.
        lo_cut->allocate(
          EXPORTING
            iv_available = '3'
          CHANGING
            ct_demands   = lt_demands ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        lv_message = lo_error->message.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Allocation demand keys are duplicated' ).
  ENDMETHOD.
ENDCLASS.
