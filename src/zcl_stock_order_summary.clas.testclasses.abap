CLASS ltcl_order_summary DEFINITION FINAL FOR TESTING DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    DATA summarizer TYPE REF TO zcl_stock_order_summary.
    DATA allocations TYPE zif_stock_alloc_types=>ty_allocations.
    METHODS setup.
    METHODS counts_mixed_components FOR TESTING RAISING zcx_stock_alloc.
    METHODS groups_orders_and_sorts FOR TESTING RAISING zcx_stock_alloc.
    METHODS reports_full_and_unfilled FOR TESTING RAISING zcx_stock_alloc.
    METHODS empty_input FOR TESTING RAISING zcx_stock_alloc.
    METHODS requires_order_origin FOR TESTING.
    METHODS rejects_invalid_results FOR TESTING.
    METHODS does_not_sum_quantities FOR TESTING RAISING zcx_stock_alloc.
    METHODS assert_rejected.
ENDCLASS.

CLASS ltcl_order_summary IMPLEMENTATION.
  METHOD setup.
    summarizer = NEW #( ).
    allocations = VALUE #(
      ( request_id = 'FULL' material = 'MAT1' plant = '1000' storage = '0001' unit = 'EA'
        required_date = '20260901' requested = 8 allocated = 8 )
      ( request_id = 'PART' material = 'MAT2' plant = '1000' storage = '0001' unit = 'KG'
        required_date = '20260923' requested = '0.300' allocated = '0.100' shortage = '0.200' )
      ( request_id = 'ZERO' material = 'MAT3' plant = '2000' storage = '0002' unit = 'L'
        required_date = '20260922' requested = 2 shortage = 2 ) ).
    LOOP AT allocations ASSIGNING FIELD-SYMBOL(<allocation>).
      <allocation>-origin = VALUE #( order_id = '000000001000'
                                     reservation = '0000000100' reservation_item = sy-tabix ).
    ENDLOOP.
  ENDMETHOD.

  METHOD counts_mixed_components.
    " Display fields are diagnostics; quantities determine the summary.
    allocations[ 1 ]-status = zif_stock_alloc_types=>status_short.
    allocations[ 3 ]-status = zif_stock_alloc_types=>status_full.
    DATA(result) = summarizer->summarize( allocations ).
    cl_abap_unit_assert=>assert_equals( act = lines( result )
                                      exp   = 1 ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-request_count
                                      exp   = 3 ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-full_count
                                      exp   = 1 ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-partial_count
                                      exp   = 1 ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-unfilled_count
                                      exp   = 1 ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-status
                                      exp   = zif_stock_alloc_types=>status_partial ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-first_shortage_date
                                      exp   = '20260922' ).
    DATA(shortages) = result[ 1 ]-shortages.
    cl_abap_unit_assert=>assert_equals( act = lines( shortages )
                                      exp   = 2 ).
    cl_abap_unit_assert=>assert_equals( act = shortages[ 1 ]
                                      exp   = allocations[ 3 ] ).
    cl_abap_unit_assert=>assert_equals( act = shortages[ 2 ]
                                      exp   = allocations[ 2 ] ).
  ENDMETHOD.

  METHOD groups_orders_and_sorts.
    allocations[ 1 ]-origin-order_id = '000000002000'.
    allocations[ 2 ]-required_date = allocations[ 3 ]-required_date.
    SORT allocations BY request_id DESCENDING.
    DATA(result) = summarizer->summarize( allocations ).
    cl_abap_unit_assert=>assert_equals( act = lines( result )
                                      exp   = 2 ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-order_id
                                      exp   = '000000001000' ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-request_count
                                      exp   = 2 ).
    cl_abap_unit_assert=>assert_equals( act = result[ 2 ]-order_id
                                      exp   = '000000002000' ).
    cl_abap_unit_assert=>assert_equals( act = result[ 2 ]-status
                                      exp   = zif_stock_alloc_types=>status_full ).
    DATA(shortages) = result[ 1 ]-shortages.
    cl_abap_unit_assert=>assert_equals( act = shortages[ 1 ]-request_id
                                      exp   = 'PART' ).
    SORT allocations BY request_id.
    cl_abap_unit_assert=>assert_equals( act = summarizer->summarize( allocations )
                                      exp   = result ).
  ENDMETHOD.

  METHOD reports_full_and_unfilled.
    DELETE allocations WHERE request_id <> 'FULL'.
    DATA(result) = summarizer->summarize( allocations ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-status
                                      exp   = zif_stock_alloc_types=>status_full ).
    cl_abap_unit_assert=>assert_initial( result[ 1 ]-first_shortage_date ).
    cl_abap_unit_assert=>assert_initial( result[ 1 ]-shortages ).
    allocations[ 1 ]-allocated = 0.
    allocations[ 1 ]-shortage = allocations[ 1 ]-requested.
    result = summarizer->summarize( allocations ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-status
                                      exp   = zif_stock_alloc_types=>status_short ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-unfilled_count
                                      exp   = 1 ).
    cl_abap_unit_assert=>assert_initial( result[ 1 ]-full_count ).
  ENDMETHOD.

  METHOD empty_input.
    cl_abap_unit_assert=>assert_initial( summarizer->summarize( VALUE #( ) ) ).
  ENDMETHOD.

  METHOD requires_order_origin.
    CLEAR allocations[ 1 ]-origin-order_id.
    assert_rejected( ).
    CLEAR allocations[ 1 ]-origin.
    assert_rejected( ).
  ENDMETHOD.

  METHOD rejects_invalid_results.
    DATA(original) = allocations.
    APPEND allocations[ 1 ] TO allocations.
    assert_rejected( ).
    allocations = original.
    allocations[ 2 ]-shortage = '0.100'.
    assert_rejected( ).
    allocations = original.
    allocations[ 1 ]-required_date = '20260229'.
    assert_rejected( ).
    allocations = original.
    CLEAR allocations[ 1 ]-origin-reservation_item.
    assert_rejected( ).
  ENDMETHOD.

  METHOD does_not_sum_quantities.
    LOOP AT allocations ASSIGNING FIELD-SYMBOL(<allocation>).
      <allocation>-requested = '9999999999.999'.
      <allocation>-allocated = <allocation>-requested.
      <allocation>-shortage = 0.
    ENDLOOP.
    DATA(result) = summarizer->summarize( allocations ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-full_count
                                      exp   = 3 ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-status
                                      exp   = zif_stock_alloc_types=>status_full ).
  ENDMETHOD.

  METHOD assert_rejected.
    TRY.
        summarizer->summarize( allocations ).
        cl_abap_unit_assert=>fail( 'Invalid order summary accepted' ).
      CATCH zcx_stock_alloc.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
