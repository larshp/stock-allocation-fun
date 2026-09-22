CLASS lcl_sources DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_stock_order_source.
    INTERFACES zif_stock_source.
    DATA response_requests TYPE zif_stock_alloc_types=>ty_requests.
    DATA response_stocks TYPE zif_stock_alloc_types=>ty_stocks.
    DATA captured_orders TYPE zif_stock_order_source=>ty_orders.
    DATA captured_date TYPE d.
    DATA captured_from TYPE d.
    DATA order_calls TYPE i.
    DATA stock_calls TYPE i.
    DATA fail_orders TYPE abap_bool.
ENDCLASS.

CLASS lcl_sources IMPLEMENTATION.
  METHOD zif_stock_order_source~read.
    order_calls = order_calls + 1.
    captured_orders = orders.
    captured_date = through_date.
    captured_from = from_date.
    IF fail_orders = abap_true.
      RAISE EXCEPTION TYPE zcx_stock_alloc
        EXPORTING reason = 'Order read failed'.
    ENDIF.
    requests = response_requests.
  ENDMETHOD.

  METHOD zif_stock_source~read.
    stock_calls = stock_calls + 1.
    stocks = response_stocks.
  ENDMETHOD.
ENDCLASS.

CLASS ltcl_order_service DEFINITION FINAL FOR TESTING DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    DATA sources TYPE REF TO lcl_sources.
    DATA service TYPE REF TO zcl_stock_order_service.
    DATA orders TYPE zif_stock_order_source=>ty_orders.
    METHODS setup RAISING zcx_stock_alloc.
    METHODS combines_sources FOR TESTING RAISING zcx_stock_alloc.
    METHODS skips_empty_work FOR TESTING RAISING zcx_stock_alloc.
    METHODS validates_selection FOR TESTING.
    METHODS validates_horizon FOR TESTING.
    METHODS inclusive_window FOR TESTING RAISING zcx_stock_alloc.
    METHODS rejects_invalid_window FOR TESTING.
    METHODS rejects_early_demand FOR TESTING.
    METHODS validates_returned_demand FOR TESTING.
    METHODS rejects_unselected_origin FOR TESTING.
    METHODS requires_returned_origin FOR TESTING.
    METHODS rejects_changed_policy FOR TESTING.
    METHODS respects_selected_orders FOR TESTING RAISING zcx_stock_alloc.
    METHODS propagates_order_errors FOR TESTING.
    METHODS requires_both_sources FOR TESTING.
    METHODS assert_selection_rejected.
ENDCLASS.

CLASS ltcl_order_service IMPLEMENTATION.
  METHOD setup.
    sources = NEW #( ).
    sources->response_requests = VALUE #( ( request_id = 'ORDER-COMPONENT' material = 'MAT1'
      plant = '1000' storage = '0001' unit = 'EA' quantity = 8
      required_date = '20260906' priority = 1 allow_partial = abap_true
      origin = VALUE #( order_id = '000000001000' ) ) ).
    sources->response_stocks = VALUE #( ( material = 'MAT1' plant = '1000' storage = '0001'
      unit = 'EA' quantity = 5 ) ).
    orders = VALUE #( ( order_id = '000000001000' priority = 1 allow_partial = abap_true ) ).
    service = NEW #( order_source = sources
                     stock_source = sources ).
  ENDMETHOD.

  METHOD combines_sources.
    DATA(result) = service->simulate( orders      = orders
                                     through_date = '20260930' ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-allocated
                                      exp   = 5 ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-shortage
                                      exp   = 3 ).
    cl_abap_unit_assert=>assert_equals( act = sources->captured_orders
                                      exp   = orders ).
    cl_abap_unit_assert=>assert_equals( act = sources->captured_date
                                      exp   = '20260930' ).
    cl_abap_unit_assert=>assert_equals( act = sources->stock_calls
                                      exp   = 1 ).
    sources->response_stocks[ 1 ]-quantity = 8.
    result = service->simulate( orders ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-allocated
                                      exp   = 8 ).
    cl_abap_unit_assert=>assert_equals( act = sources->order_calls
                                      exp   = 2 ).
    cl_abap_unit_assert=>assert_equals( act = sources->captured_date
                                      exp   = '99991231' ).
  ENDMETHOD.

  METHOD skips_empty_work.
    DATA(result) = service->simulate( VALUE #( ) ).
    cl_abap_unit_assert=>assert_initial( result ).
    cl_abap_unit_assert=>assert_initial( sources->order_calls ).
    cl_abap_unit_assert=>assert_initial( sources->stock_calls ).
    CLEAR sources->response_requests.
    result = service->simulate( orders ).
    cl_abap_unit_assert=>assert_initial( result ).
    cl_abap_unit_assert=>assert_equals( act = sources->order_calls
                                      exp   = 1 ).
    cl_abap_unit_assert=>assert_initial( sources->stock_calls ).
  ENDMETHOD.

  METHOD assert_selection_rejected.
    TRY.
        service->simulate( orders ).
        cl_abap_unit_assert=>fail( 'Invalid order selection accepted' ).
      CATCH zcx_stock_alloc.
        cl_abap_unit_assert=>assert_initial( sources->order_calls ).
        cl_abap_unit_assert=>assert_initial( sources->stock_calls ).
    ENDTRY.
  ENDMETHOD.

  METHOD validates_selection.
    APPEND orders[ 1 ] TO orders.
    assert_selection_rejected( ).
    DELETE orders INDEX 2.
    orders[ 1 ]-priority = -1.
    assert_selection_rejected( ).
    orders[ 1 ]-priority = 0.
    orders[ 1 ]-allow_partial = 'Y'.
    assert_selection_rejected( ).
    orders[ 1 ]-allow_partial = abap_true.
    CLEAR orders[ 1 ]-order_id.
    assert_selection_rejected( ).
  ENDMETHOD.

  METHOD validates_horizon.
    TRY.
        service->simulate( orders       = orders
                           through_date = '20260229' ).
        cl_abap_unit_assert=>fail( 'Invalid horizon accepted' ).
      CATCH zcx_stock_alloc.
        cl_abap_unit_assert=>assert_initial( sources->order_calls ).
    ENDTRY.
    TRY.
        service->simulate( orders       = orders
                           through_date = '20260905' ).
        cl_abap_unit_assert=>fail( 'Demand beyond horizon accepted' ).
      CATCH zcx_stock_alloc.
        cl_abap_unit_assert=>assert_equals( act = sources->order_calls
                                          exp   = 1 ).
        cl_abap_unit_assert=>assert_initial( sources->stock_calls ).
    ENDTRY.
  ENDMETHOD.

  METHOD validates_returned_demand.
    sources->response_requests[ 1 ]-quantity = 0.
    TRY.
        service->simulate( orders ).
        cl_abap_unit_assert=>fail( 'Invalid order demand accepted' ).
      CATCH zcx_stock_alloc.
        cl_abap_unit_assert=>assert_initial( sources->stock_calls ).
    ENDTRY.
  ENDMETHOD.

  METHOD rejects_unselected_origin.
    sources->response_requests[ 1 ]-origin-order_id = '000000009999'.
    TRY.
        service->simulate( orders ).
        cl_abap_unit_assert=>fail( 'Demand from an unselected order accepted' ).
      CATCH zcx_stock_alloc.
        cl_abap_unit_assert=>assert_initial( sources->stock_calls ).
    ENDTRY.
  ENDMETHOD.

  METHOD requires_returned_origin.
    CLEAR sources->response_requests[ 1 ]-origin.
    TRY.
        service->simulate( orders ).
        cl_abap_unit_assert=>fail( 'Order demand without provenance accepted' ).
      CATCH zcx_stock_alloc.
        cl_abap_unit_assert=>assert_initial( sources->stock_calls ).
    ENDTRY.
  ENDMETHOD.

  METHOD rejects_changed_policy.
    DO 2 TIMES.
      IF sy-index = 1.
        sources->response_requests[ 1 ]-priority = 0.
      ELSE.
        sources->response_requests[ 1 ]-priority = 1.
        sources->response_requests[ 1 ]-allow_partial = abap_false.
      ENDIF.
      TRY.
          service->simulate( orders ).
          cl_abap_unit_assert=>fail( 'Source changed the selected order policy' ).
        CATCH zcx_stock_alloc.
          cl_abap_unit_assert=>assert_initial( sources->stock_calls ).
      ENDTRY.
    ENDDO.
  ENDMETHOD.

  METHOD respects_selected_orders.
    APPEND VALUE #( order_id = '000000002000' priority = 0 allow_partial = abap_false ) TO orders.
    DATA(extra) = sources->response_requests[ 1 ].
    extra-request_id = 'SECOND-ORDER'.
    extra-origin-order_id = '000000002000'.
    extra-priority = 0.
    extra-allow_partial = abap_false.
    extra-quantity = 3.
    APPEND extra TO sources->response_requests.
    DATA(result) = service->simulate( orders ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-request_id
                                      exp   = 'SECOND-ORDER' ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-allocated
                                      exp   = 3 ).
    cl_abap_unit_assert=>assert_equals( act = result[ 2 ]-allocated
                                      exp   = 2 ).
    cl_abap_unit_assert=>assert_equals( act = sources->stock_calls
                                      exp   = 1 ).
  ENDMETHOD.

  METHOD inclusive_window.
    DATA(result) = service->simulate( orders       = orders
                                      through_date = '20260906'
                                      from_date    = '20260906' ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-allocated
                                      exp   = 5 ).
    cl_abap_unit_assert=>assert_equals( act = sources->captured_from
                                      exp   = '20260906' ).
    cl_abap_unit_assert=>assert_equals( act = sources->captured_date
                                      exp   = '20260906' ).
    result = service->simulate( orders ).
    cl_abap_unit_assert=>assert_equals( act = sources->captured_from
                                      exp   = '00010101' ).
  ENDMETHOD.

  METHOD rejects_invalid_window.
    DATA dates TYPE STANDARD TABLE OF d WITH DEFAULT KEY.
    dates = VALUE #( ( '00000000' ) ( '20260229' ) ( '20260908' ) ).
    LOOP AT dates INTO DATA(date).
      TRY.
          service->simulate( orders       = orders
                             through_date = '20260907'
                             from_date    = date ).
          cl_abap_unit_assert=>fail( 'Invalid order date window accepted' ).
        CATCH zcx_stock_alloc.
          cl_abap_unit_assert=>assert_initial( sources->order_calls ).
          cl_abap_unit_assert=>assert_initial( sources->stock_calls ).
      ENDTRY.
    ENDLOOP.
    TRY.
        service->simulate( orders       = VALUE #( )
                           through_date = '20260906'
                           from_date    = '20260907' ).
        cl_abap_unit_assert=>fail( 'Invalid empty-selection window accepted' ).
      CATCH zcx_stock_alloc.
        cl_abap_unit_assert=>assert_initial( sources->order_calls ).
    ENDTRY.
  ENDMETHOD.

  METHOD rejects_early_demand.
    TRY.
        service->simulate( orders    = orders
                           from_date = '20260907' ).
        cl_abap_unit_assert=>fail( 'Source demand before window accepted' ).
      CATCH zcx_stock_alloc.
        cl_abap_unit_assert=>assert_equals( act = sources->order_calls
                                          exp   = 1 ).
        cl_abap_unit_assert=>assert_initial( sources->stock_calls ).
    ENDTRY.
  ENDMETHOD.

  METHOD propagates_order_errors.
    sources->fail_orders = abap_true.
    TRY.
        service->simulate( orders ).
        cl_abap_unit_assert=>fail( 'Order read failure swallowed' ).
      CATCH zcx_stock_alloc INTO DATA(error).
        cl_abap_unit_assert=>assert_equals( act = error->reason
                                          exp   = 'Order read failed' ).
        cl_abap_unit_assert=>assert_initial( sources->stock_calls ).
    ENDTRY.
  ENDMETHOD.

  METHOD requires_both_sources.
    DATA no_orders TYPE REF TO zif_stock_order_source.
    DATA no_stock TYPE REF TO zif_stock_source.
    TRY.
        DATA(invalid) = NEW zcl_stock_order_service( order_source = no_orders
                                                    stock_source  = sources ).
        cl_abap_unit_assert=>fail( 'Missing order source accepted' ).
      CATCH zcx_stock_alloc.
    ENDTRY.
    TRY.
        invalid = NEW #( order_source = sources
                         stock_source = no_stock ).
        cl_abap_unit_assert=>fail( 'Missing stock source accepted' ).
      CATCH zcx_stock_alloc.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
