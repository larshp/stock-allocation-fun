CLASS ltcl_allocator DEFINITION FINAL FOR TESTING
  DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    DATA allocator TYPE REF TO zcl_stock_allocator.
    DATA stocks TYPE zif_stock_alloc_types=>ty_stocks.
    DATA requests TYPE zif_stock_alloc_types=>ty_requests.
    METHODS setup.
    METHODS priority_and_shortage FOR TESTING RAISING zcx_stock_alloc.
    METHODS complete_only FOR TESTING RAISING zcx_stock_alloc.
    METHODS safety_stock FOR TESTING RAISING zcx_stock_alloc.
    METHODS date_and_id_tiebreak FOR TESTING RAISING zcx_stock_alloc.
    METHODS missing_stock FOR TESTING RAISING zcx_stock_alloc.
    METHODS duplicate_request FOR TESTING.
    METHODS duplicate_stock FOR TESTING.
    METHODS unit_mismatch FOR TESTING.
    METHODS invalid_quantity FOR TESTING.
    METHODS fractional_quantity FOR TESTING RAISING zcx_stock_alloc.
    METHODS isolated_locations FOR TESTING RAISING zcx_stock_alloc.
    METHODS empty_requests FOR TESTING RAISING zcx_stock_alloc.
    METHODS invalid_date FOR TESTING.
    METHODS many_requests_conserve_stock FOR TESTING RAISING zcx_stock_alloc.
    METHODS subtracts_existing_commitments FOR TESTING RAISING zcx_stock_alloc.
    METHODS commitments_cannot_go_negative FOR TESTING.
    METHODS rounds_down_to_whole_lots FOR TESTING RAISING zcx_stock_alloc.
    METHODS fractional_lot_sizes FOR TESTING RAISING zcx_stock_alloc.
    METHODS rejects_incomplete_lot_request FOR TESTING.
    METHODS decimal_stock_conservation FOR TESTING RAISING zcx_stock_alloc.
    METHODS minimum_preserves_stock FOR TESTING RAISING zcx_stock_alloc.
    METHODS minimum_boundary FOR TESTING RAISING zcx_stock_alloc.
    METHODS minimum_after_lot_rounding FOR TESTING RAISING zcx_stock_alloc.
    METHODS fractional_minimum FOR TESTING RAISING zcx_stock_alloc.
    METHODS rejects_invalid_minimum FOR TESTING.
    METHODS explains_allocation_decisions FOR TESTING RAISING zcx_stock_alloc.
    METHODS explains_policy_precedence FOR TESTING RAISING zcx_stock_alloc.
    METHODS preserves_request_origin FOR TESTING RAISING zcx_stock_alloc.
    METHODS rejects_incomplete_origin FOR TESTING.
ENDCLASS.

CLASS ltcl_allocator IMPLEMENTATION.
  METHOD preserves_request_origin.
    requests[ 2 ]-origin = VALUE #( order_id         = '000000001000'
                                    reservation      = '0000000100'
                                    reservation_item = '0001'
                                    reservation_type = '1' ).
    DATA(result) = allocator->allocate( stocks = stocks
                                      requests = requests ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-origin
                                      exp   = requests[ 2 ]-origin ).
    cl_abap_unit_assert=>assert_initial( result[ 2 ]-origin ).
  ENDMETHOD.

  METHOD rejects_incomplete_origin.
    DATA origins TYPE STANDARD TABLE OF zif_stock_alloc_types=>ty_origin WITH DEFAULT KEY.
    origins = VALUE #( ( reservation = '0000000100' )
                       ( reservation_item = '0001' )
                       ( reservation_type = '1' ) ).
    LOOP AT origins INTO DATA(origin).
      requests[ 1 ]-origin = origin.
      TRY.
          allocator->allocate( stocks   = stocks
                               requests = requests ).
          cl_abap_unit_assert=>fail( 'Incomplete reservation origin accepted' ).
        CATCH zcx_stock_alloc.
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.

  METHOD explains_allocation_decisions.
    requests = VALUE #( ( request_id = 'A' material = 'MAT1' plant = '1000' storage = '0001'
                          unit = 'EA' quantity = 12 required_date = '20260906' allow_partial = abap_true ) ).
    stocks = VALUE #( ( material = 'MAT1' plant = '1000' storage = '0001'
                        unit = 'EA' quantity = 20 safety_stock = 2 committed = 3 ) ).
    DATA(result) = allocator->allocate( stocks = stocks
                                      requests = requests ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-reason
                                      exp   = zif_stock_alloc_types=>reason_full ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-available_before
                                      exp   = 15 ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-available_after
                                      exp   = 3 ).
    stocks[ 1 ]-quantity = 10.
    result = allocator->allocate( stocks   = stocks
                                  requests = requests ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-reason
                                      exp   = zif_stock_alloc_types=>reason_insufficient ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-available_before
                                      exp   = 5 ).
    cl_abap_unit_assert=>assert_initial( result[ 1 ]-available_after ).
    stocks[ 1 ]-quantity = 0.
    result = allocator->allocate( stocks   = stocks
                                  requests = requests ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-reason
                                      exp   = zif_stock_alloc_types=>reason_empty ).
    CLEAR stocks.
    result = allocator->allocate( stocks   = stocks
                                  requests = requests ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-reason
                                      exp   = zif_stock_alloc_types=>reason_missing ).
    cl_abap_unit_assert=>assert_initial( result[ 1 ]-available_before ).
    cl_abap_unit_assert=>assert_initial( result[ 1 ]-available_after ).
  ENDMETHOD.

  METHOD explains_policy_precedence.
    requests = VALUE #( ( request_id = 'A' material = 'MAT1' plant = '1000' storage = '0001'
                          unit = 'EA' quantity = 12 required_date = '20260906'
                          lot_size = 4 min_allocation = 9 ) ).
    stocks = VALUE #( ( material = 'MAT1' plant = '1000' storage = '0001' unit = 'EA' quantity = 10 ) ).
    DATA(result) = allocator->allocate( stocks = stocks
                                      requests = requests ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-reason
                                      exp   = zif_stock_alloc_types=>reason_complete ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-available_after
                                      exp   = 10 ).
    requests[ 1 ]-allow_partial = abap_true.
    result = allocator->allocate( stocks   = stocks
                                  requests = requests ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-reason
                                      exp   = zif_stock_alloc_types=>reason_minimum ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-available_after
                                      exp   = 10 ).
    requests[ 1 ]-min_allocation = 0.
    result = allocator->allocate( stocks   = stocks
                                  requests = requests ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-reason
                                      exp   = zif_stock_alloc_types=>reason_lot ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-available_after
                                      exp   = 2 ).
    stocks[ 1 ]-quantity = 3.
    requests[ 1 ]-min_allocation = 9.
    result = allocator->allocate( stocks   = stocks
                                  requests = requests ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-reason
                                      exp   = zif_stock_alloc_types=>reason_lot ).
    stocks[ 1 ]-quantity = 0.
    result = allocator->allocate( stocks   = stocks
                                  requests = requests ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-reason
                                      exp   = zif_stock_alloc_types=>reason_empty ).
  ENDMETHOD.

  METHOD minimum_preserves_stock.
    stocks[ 1 ]-quantity = 4.
    requests[ 2 ]-min_allocation = 5.
    DATA(result) = allocator->allocate( stocks = stocks
                                      requests = requests ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-allocated
                                      exp   = 0 ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-shortage
                                      exp   = 6 ).
    cl_abap_unit_assert=>assert_equals( act = result[ 2 ]-allocated
                                      exp   = 4 ).
  ENDMETHOD.

  METHOD minimum_boundary.
    stocks[ 1 ]-quantity = 5.
    requests[ 2 ]-min_allocation = 5.
    DATA(result) = allocator->allocate( stocks = stocks
                                      requests = requests ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-allocated
                                      exp   = 5 ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-status
                                      exp   = zif_stock_alloc_types=>status_partial ).
    stocks[ 1 ]-quantity = 10.
    result = allocator->allocate( stocks   = stocks
                                  requests = requests ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-allocated
                                      exp   = 6 ).
  ENDMETHOD.

  METHOD minimum_after_lot_rounding.
    stocks[ 1 ]-quantity = 7.
    requests[ 2 ]-quantity = 8.
    requests[ 2 ]-lot_size = 4.
    requests[ 2 ]-min_allocation = 5.
    DATA(result) = allocator->allocate( stocks = stocks
                                      requests = requests ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-allocated
                                      exp   = 0 ).
    cl_abap_unit_assert=>assert_equals( act = result[ 2 ]-allocated
                                      exp   = 7 ).
  ENDMETHOD.

  METHOD fractional_minimum.
    stocks[ 1 ]-quantity = '0.250'.
    requests[ 2 ]-quantity = '0.300'.
    requests[ 2 ]-min_allocation = '0.200'.
    requests[ 2 ]-lot_size = '0.100'.
    DATA(result) = allocator->allocate( stocks = stocks
                                      requests = requests ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-allocated
                                      exp   = '0.200' ).
    cl_abap_unit_assert=>assert_equals( act = result[ 2 ]-allocated
                                      exp   = '0.050' ).
  ENDMETHOD.

  METHOD rejects_invalid_minimum.
    DATA values TYPE STANDARD TABLE OF zif_stock_alloc_types=>ty_quantity WITH DEFAULT KEY.
    values = VALUE #( ( -1 ) ( 7 ) ).
    LOOP AT values INTO DATA(minimum).
      requests[ 2 ]-min_allocation = minimum.
      TRY.
          allocator->allocate( stocks   = stocks
                               requests = requests ).
          cl_abap_unit_assert=>fail( 'Invalid minimum accepted' ).
        CATCH zcx_stock_alloc.
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.

  METHOD rounds_down_to_whole_lots.
    requests[ 2 ]-quantity = 12.
    requests[ 2 ]-lot_size = 4.
    DATA(result) = allocator->allocate( stocks  = stocks
                                       requests = requests ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-allocated
                                        exp = 8 ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-shortage
                                        exp = 4 ).
    cl_abap_unit_assert=>assert_equals( act = result[ 2 ]-allocated
                                        exp = 2 ).
  ENDMETHOD.

  METHOD fractional_lot_sizes.
    stocks[ 1 ]-quantity = '0.250'.
    requests[ 2 ]-quantity = '0.300'.
    requests[ 2 ]-lot_size = '0.100'.
    DATA(result) = allocator->allocate( stocks  = stocks
                                       requests = requests ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-allocated
                                        exp = '0.200' ).
    cl_abap_unit_assert=>assert_equals( act = result[ 2 ]-allocated
                                        exp = '0.050' ).
  ENDMETHOD.

  METHOD rejects_incomplete_lot_request.
    requests[ 2 ]-lot_size = 4.
    TRY.
        allocator->allocate( stocks   = stocks
                             requests = requests ).
        cl_abap_unit_assert=>fail( 'Nonintegral number of lots accepted' ).
      CATCH zcx_stock_alloc.
    ENDTRY.
  ENDMETHOD.

  METHOD decimal_stock_conservation.
    stocks[ 1 ]-quantity = '0.300'.
    requests[ 1 ]-quantity = '0.200'.
    requests[ 2 ]-quantity = '0.100'.
    DATA(result) = allocator->allocate( stocks  = stocks
                                       requests = requests ).
    cl_abap_unit_assert=>assert_equals( act = result[ 2 ]-allocated
                                        exp = '0.200' ).
    cl_abap_unit_assert=>assert_equals( act = result[ 2 ]-shortage
                                        exp = 0 ).
  ENDMETHOD.

  METHOD subtracts_existing_commitments.
    stocks[ 1 ]-committed = 4.
    stocks[ 1 ]-safety_stock = 2.
    DATA(result) = allocator->allocate( stocks  = stocks
                                       requests = requests ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-allocated
                                        exp = 4 ).
    cl_abap_unit_assert=>assert_equals( act = result[ 2 ]-allocated
                                        exp = 0 ).
    stocks[ 1 ]-committed = 11.
    result = allocator->allocate( stocks   = stocks
                                  requests = requests ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-allocated
                                        exp = 0 ).
  ENDMETHOD.

  METHOD commitments_cannot_go_negative.
    stocks[ 1 ]-committed = -1.
    TRY.
        allocator->allocate( stocks   = stocks
                             requests = requests ).
        cl_abap_unit_assert=>fail( 'Negative commitment accepted' ).
      CATCH zcx_stock_alloc.
    ENDTRY.
  ENDMETHOD.

  METHOD invalid_date.
    requests[ 1 ]-required_date = '20260229'.
    TRY.
        allocator->allocate( stocks   = stocks
                             requests = requests ).
        cl_abap_unit_assert=>fail( 'Impossible requirement date accepted' ).
      CATCH zcx_stock_alloc.
    ENDTRY.
  ENDMETHOD.

  METHOD many_requests_conserve_stock.
    CLEAR requests.
    stocks[ 1 ]-quantity = 123.
    DO 1000 TIMES.
      APPEND VALUE #( request_id = |R{ sy-index }| material = 'MAT1' plant = '1000'
                      storage = '0001' unit = 'EA' quantity = '0.250'
                      priority = sy-index required_date = '20260905'
                      allow_partial = abap_true ) TO requests.
    ENDDO.
    DATA(result) = allocator->allocate( stocks  = stocks
                                       requests = requests ).
    DATA total TYPE zif_stock_alloc_types=>ty_quantity.
    LOOP AT result INTO DATA(allocation).
      total = total + allocation-allocated.
      cl_abap_unit_assert=>assert_equals( act = allocation-allocated + allocation-shortage
                                          exp = allocation-requested ).
    ENDLOOP.
    cl_abap_unit_assert=>assert_equals( act = total
                                        exp = 123 ).
    cl_abap_unit_assert=>assert_equals( act = lines( result )
                                        exp = 1000 ).
    cl_abap_unit_assert=>assert_equals( act = result[ 492 ]-status
                                        exp = 'FULL' ).
    cl_abap_unit_assert=>assert_equals( act = result[ 493 ]-status
                                        exp = 'SHORTAGE' ).
  ENDMETHOD.

  METHOD setup.
    allocator = NEW #( ).
    stocks = VALUE #( ( material = 'MAT1' plant = '1000' storage = '0001'
                        unit = 'EA' quantity = 10 ) ).
    requests = VALUE #( ( request_id = 'A' material = 'MAT1' plant = '1000' storage = '0001'
                          unit = 'EA' quantity = 7 priority = 2 required_date = '20260905'
                          allow_partial = abap_true )
                        ( request_id = 'B' material = 'MAT1' plant = '1000' storage = '0001'
                          unit = 'EA' quantity = 6 priority = 1 required_date = '20260905'
                          allow_partial = abap_true ) ).
  ENDMETHOD.

  METHOD priority_and_shortage.
    DATA(result) = allocator->allocate( stocks  = stocks
                                       requests = requests ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-request_id
                                        exp = 'B' ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-allocated
                                        exp = 6 ).
    cl_abap_unit_assert=>assert_equals( act = result[ 2 ]-allocated
                                        exp = 4 ).
    cl_abap_unit_assert=>assert_equals( act = result[ 2 ]-shortage
                                        exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = result[ 2 ]-status
                                        exp = 'PARTIAL' ).
    cl_abap_unit_assert=>assert_equals( act = stocks[ 1 ]-quantity
                                        exp = 10 ).
  ENDMETHOD.

  METHOD complete_only.
    requests[ 2 ]-quantity = 11.
    requests[ 2 ]-allow_partial = abap_false.
    DATA(result) = allocator->allocate( stocks  = stocks
                                       requests = requests ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-allocated
                                        exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = result[ 2 ]-allocated
                                        exp = 7 ).
  ENDMETHOD.

  METHOD safety_stock.
    stocks[ 1 ]-safety_stock = 8.
    DATA(result) = allocator->allocate( stocks  = stocks
                                       requests = requests ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-allocated
                                        exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = result[ 2 ]-allocated
                                        exp = 0 ).
    stocks[ 1 ]-safety_stock = 20.
    result = allocator->allocate( stocks   = stocks
                                  requests = requests ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-allocated
                                        exp = 0 ).
  ENDMETHOD.

  METHOD date_and_id_tiebreak.
    requests[ 1 ]-priority = 1.
    DATA(result) = allocator->allocate( stocks  = stocks
                                       requests = requests ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-request_id
                                        exp = 'A' ).
    requests[ 2 ]-required_date = '20260904'.
    result = allocator->allocate( stocks   = stocks
                                  requests = requests ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-request_id
                                        exp = 'B' ).
  ENDMETHOD.

  METHOD missing_stock.
    CLEAR stocks.
    DATA(result) = allocator->allocate( stocks  = stocks
                                       requests = requests ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-shortage
                                        exp = 6 ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-status
                                        exp = 'SHORTAGE' ).
  ENDMETHOD.

  METHOD duplicate_request.
    requests[ 2 ]-request_id = 'A'.
    TRY.
        allocator->allocate( stocks   = stocks
                             requests = requests ).
        cl_abap_unit_assert=>fail( 'Duplicate request accepted' ).
      CATCH zcx_stock_alloc.
    ENDTRY.
  ENDMETHOD.

  METHOD duplicate_stock.
    APPEND stocks[ 1 ] TO stocks.
    TRY.
        allocator->allocate( stocks   = stocks
                             requests = requests ).
        cl_abap_unit_assert=>fail( 'Duplicate stock accepted' ).
      CATCH zcx_stock_alloc.
    ENDTRY.
  ENDMETHOD.

  METHOD unit_mismatch.
    requests[ 2 ]-unit = 'KG'.
    TRY.
        allocator->allocate( stocks   = stocks
                             requests = requests ).
        cl_abap_unit_assert=>fail( 'Mixed units accepted' ).
      CATCH zcx_stock_alloc.
    ENDTRY.
  ENDMETHOD.

  METHOD invalid_quantity.
    requests[ 1 ]-quantity = -1.
    TRY.
        allocator->allocate( stocks   = stocks
                             requests = requests ).
        cl_abap_unit_assert=>fail( 'Negative request accepted' ).
      CATCH zcx_stock_alloc.
    ENDTRY.
  ENDMETHOD.

  METHOD fractional_quantity.
    stocks[ 1 ]-quantity = '0.125'.
    DATA(result) = allocator->allocate( stocks  = stocks
                                       requests = requests ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-allocated
                                        exp = '0.125' ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-shortage
                                        exp = '5.875' ).
  ENDMETHOD.

  METHOD isolated_locations.
    requests[ 2 ]-storage = '0002'.
    DATA(result) = allocator->allocate( stocks  = stocks
                                       requests = requests ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-allocated
                                        exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = result[ 2 ]-allocated
                                        exp = 7 ).
  ENDMETHOD.

  METHOD empty_requests.
    CLEAR requests.
    DATA(result) = allocator->allocate( stocks  = stocks
                                       requests = requests ).
    cl_abap_unit_assert=>assert_initial( result ).
  ENDMETHOD.
ENDCLASS.
