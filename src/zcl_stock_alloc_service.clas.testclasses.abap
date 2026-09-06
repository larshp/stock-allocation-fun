CLASS lcl_source DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_stock_source.
    DATA stocks TYPE zif_stock_alloc_types=>ty_stocks.
    DATA requests TYPE zif_stock_alloc_types=>ty_requests.
    DATA calls TYPE i.
    DATA fail_read TYPE abap_bool.
ENDCLASS.

CLASS lcl_source IMPLEMENTATION.
  METHOD zif_stock_source~read.
    calls = calls + 1.
    me->requests = requests.
    IF fail_read = abap_true.
      RAISE EXCEPTION TYPE zcx_stock_alloc
        EXPORTING reason = 'Stock source unavailable'.
    ENDIF.
    stocks = me->stocks.
  ENDMETHOD.
ENDCLASS.

CLASS ltcl_service DEFINITION FINAL FOR TESTING DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    DATA source TYPE REF TO lcl_source.
    DATA requests TYPE zif_stock_alloc_types=>ty_requests.
    METHODS setup.
    METHODS requires_source FOR TESTING.
    METHODS empty_skips_source FOR TESTING RAISING zcx_stock_alloc.
    METHODS validates_before_read FOR TESTING.
    METHODS propagates_read_failure FOR TESTING.
    METHODS validates_source_results FOR TESTING.
    METHODS fresh_snapshot_each_time FOR TESTING RAISING zcx_stock_alloc.
    METHODS inclusive_date_window FOR TESTING RAISING zcx_stock_alloc.
    METHODS empty_window_skips_read FOR TESTING RAISING zcx_stock_alloc.
    METHODS rejects_invalid_window FOR TESTING.
    METHODS validates_excluded_demand FOR TESTING.
ENDCLASS.

CLASS ltcl_service IMPLEMENTATION.
  METHOD inclusive_date_window.
    DATA(extra) = requests[ 1 ].
    extra-request_id = 'BEFORE'.
    extra-required_date = '20260905'.
    APPEND extra TO requests.
    extra-request_id = 'END'.
    extra-required_date = '20260907'.
    APPEND extra TO requests.
    extra-request_id = 'AFTER'.
    extra-required_date = '20260908'.
    APPEND extra TO requests.
    DATA(service) = NEW zcl_stock_alloc_service( source ).
    DATA(result) = service->simulate( requests    = requests
                                     from_date    = '20260906'
                                     through_date = '20260907' ).
    cl_abap_unit_assert=>assert_equals( act = lines( result )
                                      exp   = 2 ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-request_id
                                      exp   = 'A' ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-allocated
                                      exp   = 10 ).
    cl_abap_unit_assert=>assert_equals( act = result[ 2 ]-request_id
                                      exp   = 'END' ).
    cl_abap_unit_assert=>assert_equals( act = lines( source->requests )
                                      exp   = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lines( requests )
                                      exp   = 4 ).
  ENDMETHOD.

  METHOD empty_window_skips_read.
    DATA(service) = NEW zcl_stock_alloc_service( source ).
    DATA(result) = service->simulate( requests = requests
                                     from_date = '20261001' ).
    cl_abap_unit_assert=>assert_initial( result ).
    cl_abap_unit_assert=>assert_initial( source->calls ).
    result = service->simulate( requests    = requests
                               through_date = '20260905' ).
    cl_abap_unit_assert=>assert_initial( result ).
    cl_abap_unit_assert=>assert_initial( source->calls ).
  ENDMETHOD.

  METHOD rejects_invalid_window.
    TRY.
        DATA(service) = NEW zcl_stock_alloc_service( source ).
        service->simulate( requests     = requests
                           from_date    = '20260907'
                           through_date = '20260906' ).
        cl_abap_unit_assert=>fail( 'Reversed simulation window accepted' ).
      CATCH zcx_stock_alloc.
        cl_abap_unit_assert=>assert_initial( source->calls ).
    ENDTRY.
    TRY.
        service->simulate( requests  = VALUE #( )
                           from_date = '20260229' ).
        cl_abap_unit_assert=>fail( 'Invalid date accepted for empty work' ).
      CATCH zcx_stock_alloc.
        cl_abap_unit_assert=>assert_initial( source->calls ).
    ENDTRY.
  ENDMETHOD.

  METHOD validates_excluded_demand.
    requests[ 1 ]-quantity = -1.
    TRY.
        DATA(service) = NEW zcl_stock_alloc_service( source ).
        service->simulate( requests  = requests
                           from_date = '20261001' ).
        cl_abap_unit_assert=>fail( 'Filtering concealed invalid input' ).
      CATCH zcx_stock_alloc.
        cl_abap_unit_assert=>assert_initial( source->calls ).
    ENDTRY.
  ENDMETHOD.

  METHOD setup.
    source = NEW #( ).
    source->stocks = VALUE #( ( material = 'MAT1' plant = '1000' storage = '0001'
                                unit = 'EA' quantity = 10 ) ).
    requests = VALUE #( ( request_id = 'A' material = 'MAT1' plant = '1000' storage = '0001'
                          unit = 'EA' quantity = 12 required_date = '20260906' allow_partial = abap_true ) ).
  ENDMETHOD.

  METHOD requires_source.
    DATA unbound TYPE REF TO zif_stock_source.
    TRY.
        DATA(service) = NEW zcl_stock_alloc_service( unbound ).
        cl_abap_unit_assert=>fail( 'Unbound source accepted' ).
      CATCH zcx_stock_alloc.
    ENDTRY.
  ENDMETHOD.

  METHOD empty_skips_source.
    DATA(service) = NEW zcl_stock_alloc_service( source ).
    DATA(result) = service->simulate( VALUE #( ) ).
    cl_abap_unit_assert=>assert_initial( result ).
    cl_abap_unit_assert=>assert_equals( act = source->calls
                                      exp   = 0 ).
  ENDMETHOD.

  METHOD validates_before_read.
    requests[ 1 ]-required_date = '20260229'.
    TRY.
        DATA(service) = NEW zcl_stock_alloc_service( source ).
        service->simulate( requests ).
        cl_abap_unit_assert=>fail( 'Invalid demand accepted' ).
      CATCH zcx_stock_alloc.
        cl_abap_unit_assert=>assert_equals( act = source->calls
                                          exp   = 0 ).
    ENDTRY.
  ENDMETHOD.

  METHOD propagates_read_failure.
    source->fail_read = abap_true.
    TRY.
        DATA(service) = NEW zcl_stock_alloc_service( source ).
        service->simulate( requests ).
        cl_abap_unit_assert=>fail( 'Read failure was swallowed' ).
      CATCH zcx_stock_alloc INTO DATA(error).
        cl_abap_unit_assert=>assert_equals( act = error->reason
                                          exp   = 'Stock source unavailable' ).
        cl_abap_unit_assert=>assert_equals( act = source->calls
                                          exp   = 1 ).
    ENDTRY.
  ENDMETHOD.

  METHOD validates_source_results.
    APPEND source->stocks[ 1 ] TO source->stocks.
    TRY.
        DATA(service) = NEW zcl_stock_alloc_service( source ).
        service->simulate( requests ).
        cl_abap_unit_assert=>fail( 'Duplicate stock from source accepted' ).
      CATCH zcx_stock_alloc.
        cl_abap_unit_assert=>assert_equals( act = source->calls
                                          exp   = 1 ).
    ENDTRY.
  ENDMETHOD.

  METHOD fresh_snapshot_each_time.
    DATA(service) = NEW zcl_stock_alloc_service( source ).
    DATA(first) = service->simulate( requests ).
    source->stocks[ 1 ]-quantity = 3.
    DATA(second) = service->simulate( requests ).
    cl_abap_unit_assert=>assert_equals( act = first[ 1 ]-allocated
                                      exp   = 10 ).
    cl_abap_unit_assert=>assert_equals( act = second[ 1 ]-allocated
                                      exp   = 3 ).
    cl_abap_unit_assert=>assert_equals( act = source->requests
                                      exp   = requests ).
    cl_abap_unit_assert=>assert_equals( act = source->calls
                                      exp   = 2 ).
    cl_abap_unit_assert=>assert_equals( act = source->stocks[ 1 ]-quantity
                                      exp   = 3 ).
  ENDMETHOD.
ENDCLASS.
