CLASS ltcl_stock_allocator_auto DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS uses_priority_when_covered FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS uses_fair_share_when_scarce FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_duplicate_keys FOR TESTING
      RAISING zcx_stock_allocation.
ENDCLASS.

CLASS ltcl_stock_allocator_auto IMPLEMENTATION.
  METHOD uses_priority_when_covered.
    DATA lo_cut TYPE REF TO zif_stock_allocation.
    DATA lt_demands TYPE zif_stock_allocation=>tt_demands.

    CREATE OBJECT lo_cut TYPE zcl_stock_allocator_auto.
    APPEND VALUE #( order_id  = 'LOW'
                    priority  = 1
                    requested = '2' ) TO lt_demands.
    APPEND VALUE #( order_id  = 'HIGH'
                    priority  = 10
                    requested = '2' ) TO lt_demands.

    lo_cut->allocate(
      EXPORTING
        iv_available = '4'
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
      exp = 'F' ).
  ENDMETHOD.

  METHOD uses_fair_share_when_scarce.
    DATA lo_cut TYPE REF TO zif_stock_allocation.
    DATA lt_demands TYPE zif_stock_allocation=>tt_demands.
    DATA lv_remaining TYPE zif_stock_allocation=>ty_quantity.

    CREATE OBJECT lo_cut TYPE zcl_stock_allocator_auto.
    APPEND VALUE #( order_id  = 'FIRST'
                    priority  = 10
                    requested = '9' ) TO lt_demands.
    APPEND VALUE #( order_id  = 'SECOND'
                    priority  = 1
                    requested = '9' ) TO lt_demands.

    lv_remaining = lo_cut->allocate(
      EXPORTING
        iv_available = '6'
      CHANGING
        ct_demands   = lt_demands ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ order_id = 'FIRST' ]-allocated
      exp = '3' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ order_id = 'SECOND' ]-allocated
      exp = '3' ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_remaining
      exp = '0' ).
  ENDMETHOD.

  METHOD rejects_duplicate_keys.
    DATA lo_cut TYPE REF TO zif_stock_allocation.
    DATA lt_demands TYPE zif_stock_allocation=>tt_demands.
    DATA lv_raised TYPE abap_bool.
    DATA lv_message TYPE c LENGTH 220.

    CREATE OBJECT lo_cut TYPE zcl_stock_allocator_auto.
    APPEND VALUE #( order_id = 'DUPLICATE' requested = '1' ) TO lt_demands.
    APPEND VALUE #( order_id = 'DUPLICATE' requested = '2' ) TO lt_demands.
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
