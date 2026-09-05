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
ENDCLASS.

CLASS ltcl_allocator IMPLEMENTATION.
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
